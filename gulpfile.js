require('coffee-script/register');

var fs = require('fs');
var tasks = fs.readdirSync('./gulp/');

tasks.forEach(function(task) {
	if (task.slice(-3) === '.js' || task.slice(-7) === '.coffee') {
		require('./gulp/' + task);
	}
});
