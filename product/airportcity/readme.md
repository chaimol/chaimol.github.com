readme.md

做该网站遇到的问题与解决方案

1.判断鼠标进入离开该元素的方向。
	+使用jquery写了一个封装函数，获取鼠标离开进入元素的位置后运算，给出方向。
	+使用到Math.round(四舍五入)，	
	+Math.PI(π)，Math.atan2(x,y)：返回-PI 到 PI 之间的值，是从 X 轴正向逆时针旋转到点 (x,y) 时经过的角度。	
2.关于iframe使用时，fixed元素的位置变化的问题。
	页面通过iframe引入的子页面的元素里有fixed定位的，在新页面定位会失效。fixed只是相对原来的页面fixed。
	解决方案：使用js控制定位。
		$(parent.window).scroll(function(){
		  $('#header_fixed').css({
		    top : $(parent.window).scrollTop();
		  });
		});	
3.使用百度地图api，做出页面内的地图。
	百度给的有API比较好用。先申请自己的秘钥ak值。API文档地址http://developer.baidu.com/map/jsdemo.htm#a1_2
4.引入iframe高度自适应的问题。
	通过js动态获取引入的页面的高度，设置iframe元素的高度