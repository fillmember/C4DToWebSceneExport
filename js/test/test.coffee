Debug = require 'Debug'
Animation = require 'Animation'

test = new Debug.Test ->
	animation = JSON.parse require('raw!./testData.js')
	console.log animation
	#
	name = 'orange_1'
	ry = 'ry'
	test.log '<h1>Animation Class Unit Test</h1>'
	test.log 'Check console for raw animation data. <br/>'
	test.log '<h2>Animation.animationValueAt(animation,obj,track,t)</h2>'
	test.log 'start time: ' + Date.now()
	startTime = Date.now()
	test.log 'value at '+0+'&nbsp;&nbsp;:&nbsp;' + Animation.animationValueAt animation , name , ry , 0
	test.log 'value at '+1+'&nbsp;&nbsp;:&nbsp;' + Animation.animationValueAt animation , name , ry , 1
	test.log 'value at '+2+'&nbsp;&nbsp;:&nbsp;' + Animation.animationValueAt animation , name , ry , 2
	test.log 'value at '+3+'&nbsp;&nbsp;:&nbsp;' + Animation.animationValueAt animation , name , ry , 3
	test.log 'value at '+4+'&nbsp;&nbsp;:&nbsp;' + Animation.animationValueAt animation , name , ry , 4
	test.log 'value at '+5+'&nbsp;&nbsp;:&nbsp;' + Animation.animationValueAt animation , name , ry , 5
	test.log 'value at '+6+'&nbsp;&nbsp;:&nbsp;' + Animation.animationValueAt animation , name , ry , 6
	test.log 'value at '+7+'&nbsp;&nbsp;:&nbsp;' + Animation.animationValueAt animation , name , ry , 7
	test.log 'value at '+8+'&nbsp;&nbsp;:&nbsp;' + Animation.animationValueAt animation , name , ry , 8
	test.log 'value at '+9+'&nbsp;&nbsp;:&nbsp;' + Animation.animationValueAt animation , name , ry , 9
	test.log 'value at '+10+'&nbsp;:&nbsp;'      + Animation.animationValueAt animation , name , ry , 10
	test.log "time elapsed: #{Date.now() - startTime} (ms)"
	test.log '&nbsp;'
	test.log '<h2>Animation.trackValueAt(track,t)</h2>'
	test.log 'start time: ' + Date.now()
	startTime = Date.now()
	track = animation[name][ry]
	test.log 'value at '+0+'&nbsp;&nbsp;:&nbsp;' + Animation.trackValueAt track , 0
	test.log 'value at '+1+'&nbsp;&nbsp;:&nbsp;' + Animation.trackValueAt track , 1
	test.log 'value at '+2+'&nbsp;&nbsp;:&nbsp;' + Animation.trackValueAt track , 2
	test.log 'value at '+3+'&nbsp;&nbsp;:&nbsp;' + Animation.trackValueAt track , 3
	test.log 'value at '+4+'&nbsp;&nbsp;:&nbsp;' + Animation.trackValueAt track , 4
	test.log 'value at '+5+'&nbsp;&nbsp;:&nbsp;' + Animation.trackValueAt track , 5
	test.log 'value at '+6+'&nbsp;&nbsp;:&nbsp;' + Animation.trackValueAt track , 6
	test.log 'value at '+7+'&nbsp;&nbsp;:&nbsp;' + Animation.trackValueAt track , 7
	test.log 'value at '+8+'&nbsp;&nbsp;:&nbsp;' + Animation.trackValueAt track , 8
	test.log 'value at '+9+'&nbsp;&nbsp;:&nbsp;' + Animation.trackValueAt track , 9
	test.log 'value at '+10+'&nbsp;:&nbsp;'      + Animation.trackValueAt track , 10
	test.log "time elapsed: #{Date.now() - startTime} (ms)"
	test.log '&nbsp;'
	test.log '<h2>Original Data : </h2>'
	do =>
		trk = animation[name][ry]
		trk.in.forEach (value,index) =>
			test.log 'in: ' + trk.in[index] + ' out: ' + trk.out[index] + ' interpolation : ' + trk.ipo[index]
