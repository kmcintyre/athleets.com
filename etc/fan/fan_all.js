define(["jquery"], function($) {

    function fan(d) {
    	var ang = Math.PI/d.length
  		for (var c = 0; c < d.length; c++) {
  			console.log('add image:' + ang * c)
  			var img = new Image();
  			img.onload = function() {  				
				var ctx = $('#logo')[0].getContext('2d');
				ctx.save();				
				console.log(img.width);
	  			console.log(img.height);				
				//ctx.rotate(-ang*c);
				ctx.drawImage(img, 25, 25,  img.width, img.height);
				ctx.restore();				
      		};
      		console.log(d[c])
      		img.src = d[c];
  		}
	}
	$(document).ready(function() {
		d = [ '1.png', '2.png', '3.png'];
		fan(d);
	});
});
