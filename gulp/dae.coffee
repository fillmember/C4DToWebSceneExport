gulp = require 'gulp'
config = require './config'

yargs = require 'yargs'
chalk = require 'chalk'
run   = require 'run-sequence'

gulp.task 'watch-dae' , (cb) ->
	gulp.watch '3d/*.dae' , ['dae']

gulp.task 'dae' , (cb) ->

	argv = DAEProcess.yarg()
	input  = argv.input
	output = argv.output

	gulp.src input
		.pipe DAEProcess.stream()
		.pipe gulp.dest output

class DAEProcess

	@dictionary =
		interpolations:
			'STEP'   : 0
			'LINEAR' : 1
			'BEZIER' : 2
		tracks:
			# Position
			'translate.X' : 'px'
			'translate.Y' : 'py'
			'translate.Z' : 'pz'
			# Scale
			'scale.X' : 'sx'
			'scale.Y' : 'sy'
			'scale.Z' : 'sz'
			# Rotation (Angle)
			'rotateX.ANGLE' : 'rx'
			'rotateY.ANGLE' : 'ry'
			'rotateZ.ANGLE' : 'rz'

	@yarg = ->
		yargs
			.alias   'input' , 'i'
			.default 'input' , '3d/input/*.dae'
			.alias   'output' , 'o'
			.default 'output' , '3d/output/'
			.boolean 'animation'
			.default 'animation' , true
			.boolean 'scene'
			.default 'scene' , true
			.alias   'pretty' , 'p'
			.boolean 'pretty'
			.argv

	@stream = ->
		Stream = require 'stream'
		Path = require 'path'
		stream = new Stream.Transform objectMode : true
		stream._transform = (file, encoding, cb) ->
			source_path = file.path
			finish = -> cb null , file
			# animation.js
			data = DAEProcess.parse String(file.contents)
			data = JSON.stringify data
			file.contents = new Buffer data
			file.path = do ->
				p = Path.parse( file.path )
				"#{p.dir}/#{p.name}-animation.js"
			# scene.js
			DAEProcess.genScene source_path , finish
		return stream

	@genScene = (input,callback=->) ->
		argv = DAEProcess.yarg()
		Path = require 'path'
		p = Path.parse input
		output = argv.output + p.name + '-scene.js'
		spawn = require('child_process').spawn
		args = [ 'python/convert2threejs.py' , input , output ]
		if argv.pretty then args.push '-p'
		args.push '--no-texture-copy' if not argv.texture
		pyp = spawn 'python' , args
		pyp.stdout.on 'data' , (data) -> process.stdout.write chalk.gray data
		pyp.stderr.on 'data' , (data) -> process.stdout.write chalk.red data
		pyp.on 'close' , (code, signal) ->
			if code is 0
				console.log chalk.green chalk.green('Scene data exported:'),output
				callback()

	@read = (path, callback = ->) ->
		fs = require 'fs'
		fs.readFile path , 'utf-8' , (err, data) =>
			if err
				callback err , null
				throw err
			callback null , @parse data

	@parse = (data) ->
		cheerio = require 'cheerio'
		$ = cheerio.load data , xmlMode : true

		result = {}

		$('library_animations animation channel').each (index) ->
			$this = $(this)
			# Get Target Name
			[ targetID , track ] = $this.attr('target').split('/')
			target = $("library_visual_scenes node[id=#{targetID}]").attr('name')
			# Get Keyframes
			$sampler = $this.siblings('sampler')
			inputID  = $sampler.find('input[semantic=INPUT]').attr('source')
			outputID = $sampler.find('input[semantic=OUTPUT]').attr('source')
			input    = $(inputID).children('float_array').html().split(' ')
			output   = $(outputID).children('float_array').html().split(' ')
			# Get Details
			interpolID   = $sampler.find('input[semantic=INTERPOLATION]').attr('source')
			inTangentID  = $sampler.find('input[semantic=IN_TANGENT]').attr('source')
			outTangentID = $sampler.find('input[semantic=OUT_TANGENT]').attr('source')
			interpol     = $(interpolID).children('Name_array').html().split(' ')
			inTangent    = $(inTangentID).children('float_array').html().split(' ')
			outTangent   = $(outTangentID).children('float_array').html().split(' ')
			# Convert degress to radian
			if track.indexOf('rotate') > -1
				output = output.map DAEProcess.toRadian
			# Write to result
			if !result[ target ]? then result[ target ] = {}
			result[ target ][ DAEProcess.getTrackName(track) ] =
				in  : DAEProcess.parseFloatArray input
				out : DAEProcess.parseFloatArray output
				ipo : DAEProcess.parseNameArray interpol
				# tan : DAEProcess.parseTangentArray inTangent , outTangent

		return result

	@parseNameArray = (input) -> input.map (x) => @dictionary.interpolations[x] ? x

	@parseFloatArray = (input, precision=10000) ->
		input.map (x) -> Math.round( parseFloat(x) * precision ) / precision

	@parseTangentArray = ( inTangents , outTangents ) ->
		inTangents  = @parseFloatArray inTangents  , 100
		outTangents = @parseFloatArray outTangents , 100
		tangents = []
		loop
			tangents.push inTangents.shift()
			tangents.push outTangents.shift()
			# shift out position : this info is already in position
			inTangents.shift()
			outTangents.shift()
			break if inTangents.length < 1
		return tangents

	@getTrackName = (input) -> @dictionary.tracks[input] ? input

	@toRadian = (deg) -> deg * Math.PI / 180
