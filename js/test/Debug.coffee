class Debug
	class Test
		constructor:(start)->
			require('./unit-test.css')
			@testWrapper = document.createElement('div')
			@testWrapper.setAttribute 'id' , 'testWrapper'
			document.body.append(@testWrapper)

		log: (content) ->
			if !@console?
				@console = document.createElement('code')
				@console.setAttribute 'id' , 'console'
				@testWrapper.append(@console)
			#
			type = typeof content
			switch type
				when 'string'
					span = document.createElement('span')
					span.innerHTML = "#{content}<br/>"
					@console.append(span)
				when 'object'
					if content instanceof HTMLElement
						@console.append(content)
					else
						throw 'cannot handle object : ' + object
				else
					throw 'cannot handle type : ' + type

	Debug.Test = Test

module.exports = Debug
