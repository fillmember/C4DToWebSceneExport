gsap = require 'gsap'

module.exports = class Animation

	@DefaultTransformFunction = (x) -> x
	@dictionary = {
		tracks : {
			# id : object3d     target            property
			'px' : (obj3d) -> [ obj3d.position , 'x' ]
			'py' : (obj3d) -> [ obj3d.position , 'y' ]
			'pz' : (obj3d) -> [ obj3d.position , 'z' ]
			'sx' : (obj3d) -> [ obj3d.scale    , 'x' ]
			'sy' : (obj3d) -> [ obj3d.scale    , 'y' ]
			'sz' : (obj3d) -> [ obj3d.scale    , 'z' ]
			'rx' : (obj3d) -> [ obj3d.rotation , 'x' ]
			'ry' : (obj3d) -> [ obj3d.rotation , 'y' ]
			'rz' : (obj3d) -> [ obj3d.rotation , 'z' ]
		}
		interpolations : {
			'0' : SteppedEase.config(0)   # STEP
			'1' : Power0.easeNone         # LINEAR
			'2' : Power2.easeInOut        # BEZIER
			'3' : Power3.easeInOut
			'4' : Power4.easeInOut        # Custom etc...
			'5' : Expo.easeIn
		}
	}

	constructor : ->

	###*
	 * Bind animation data to a THREE.Scene/THREE.Object3D instance.
	 * @param  {object}         animation    animation data
	 * @param  {THREE.Object3d} scene        THREE Object3D instance to animate
	 * @param  {object}         options      specify what to exclude, useFromTo... etc
	 * @return {GSAP TimelineMax}
	###
	bind: (animation,scene,options={}) ->
		group = new TimelineMax
		for obj_name of animation
			# check excluded names
			if options.exclude?
				skip = false
				for exclude_name in options.exclude
					if obj_name.indexOf('exclude_name') > -1
						skip = true
				if skip then continue
			# Check if obj3d with name exist
			obj3d = scene.getObjectByName obj_name
			if !obj3d? then continue
			#
			trackTargetAndProperty = Animation.dictionary.tracks[track](obj3d)
			# generate TimelineMax for each track
			for track of animation[obj_name]
				timeline = @makeTrackTimeline({
					target    : trackTargetAndProperty[0]
					property  : trackTargetAndProperty[1]
					track     : animation[obj_name][track]
					useFromTo : options.useFromTo
				})
				group.add timeline , 0
		return group

	###*
	 * Make a GSAP TimelineMax from one track in animation data
	 * @return {GSAP TimelineMax}
	###
	makeTrackTimeline: ({
		target
		property
		track
		transform = Animation.DefaultTransformFunction
		useFromTo = false
	}) ->
		timeline = new TimelineMax
		i = 0
		loop
			if useFromTo
				# FromTo System : more rigid, do what C4D timeline does normally
				from_t = track.in[i]
				duration = track.in[i+1] - track.in[i]
				from = {}
				from[property] = transform track.out[i]
				to = {
					ease : Animation.dictionary.interpolations[track.ipo[i]]
				}
				to[property] = transform track.out[i+1]
				timeline.fromTo target , duration , from , to , from_t
			else
				# To only system : more flexible
				if i > 0
					duration = track.in[i] - track.in[i-1]
					position = track.in[i-1]
				else
					duration = 0
					position = 0
				to_vars = {
					ease : Animation.dictionary.interpolations[track.ipo[i-1||0]]
				}
				to_vars[property] = transform track.out[i]
				timeline.to target , duration , to_vars , position
			# Loop Control
			i++
			break if !track.in[i]?
		return timeline

	###*
	 *
	 * Helper Functions
	 *
	###

	animationValueAt: (animation,obj,track,t) ->
		if !animation[obj]?
			console.error "Cannot find obj_name #{obj} in animation data: #{animation}"
			return null
		if !animation[obj][track]?
			console.error "Cannot find track #{track} of #{obj} in animation data: #{animation}"
			return null
		return @trackValueAt animation[obj][track] , t

	trackValueAt: (track,t) ->
		if !track? then return null
		# Generate Timeline with a dummy property
		dummyObject = {}
		dummyObject.dummyProperty = 0
		# Seek to t and get the value
		@makeTrackTimeline({
			target    : dummyObject
			property  : 'dummyProperty'
			track     : track
			useFromTo : true
		}).seek(t).kill()
		# Return current property state
		return dummyObject.dummyProperty

	tweenValuesAt = (tween,property,time) ->
		dummyObject = {}
		dummyObject[property] = 0
		TweenMax.to( dummyObject , tween._duration , tween.vars ).seek(time).kill();
		return dummyObject[property]
