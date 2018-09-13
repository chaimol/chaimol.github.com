//2015.11.2  百度首页完整版开发
$(document).ready(function() {
//左部菜单栏start
   $("#left_menu_ul li").each(function(index) {
     $(this).mouseover(function() {
         $("#left_menu_ul li").eq(index).addClass("bgColor");
     });
     $(this).mouseleave(function() {
         $("#left_menu_ul li").eq(index).removeClass("bgColor");
     });
     $("div.Right-content").eq(0).addClass("disp-on");
     $(this).click(function(){
     	$("#left_menu_ul li").removeClass("select1");
     	$("#left_menu_ul li").eq(index).addClass("select1");
     	$("div.Right-content").removeClass("disp-on");
        $("div.Right-content").addClass("disp-off");
        $("div.Right-content").eq(index).removeClass("disp-off");
     	$("div.Right-content").eq(index).addClass("disp-on");
     });
 });
 //左部菜单栏end
 //内容1start
 $("#middle_right_manu a").each(function(index){
 	$(this).click(function(){
 		$("#middle_right_manu a.bgColor2").removeClass("bgColor2");
 		$("#middle_right_manu a").eq(index).addClass("bgColor2");
        $(".content0-select").removeClass("disp-on");
        $(".content0-select").addClass("disp-off");
        $(".content0-select").eq(index).removeClass("disp-off");
        $(".content0-select").eq(index).addClass("disp-on");
 	});
 });	
 	
//内容1end
//内容2 start
            (new CenterImgPlay()).Start();
        function CenterImgPlay() {
            this.list = $(".imgbox").children(":first").children();
            this.indexs = [];
            this.length = this.list.length;
            //图片显示时间
            this.timer = 3000;
            this.showTitle = $(".title");

            var index = 0, self = this, pre = 0, handid, isPlay = false, isPagerClick = false;

            this.Start = function () {
                this.Init();
                //计时器，用于定时轮播图片
                handid = setInterval(self.Play, this.timer);
            };
            //初始化
            this.Init = function () {
                var o = $(".pager ul li"), _i;

                for (var i = o.length - 1, n = 0; i >= 0; i--, n++) {
                    this.indexs[n] = o.eq(i).click(self.PagerClick);
                }
            };
            this.Play = function () {
                isPlay = true;
                index++;
                if (index == self.length) {
                    index = 0;
                }
                //先淡出，在回调函数中执行下一张淡入
                self.list.eq(pre).fadeOut(300, "linear", function () {
                    var info = self.list.eq(index).fadeIn(500, "linear", function () {
                        isPlay = false;
                        if (isPagerClick) { handid = setInterval(self.Play, self.timer); isPagerClick = false; }
                    }).attr("title");
                    //显示标题
                    self.showTitle.text(info);
                    //图片序号背景更换
                    self.indexs[index].addClass("border_select");
                    self.indexs[pre].addClass("border_select");

                    pre = index;
                });
            };
            //图片序号点击
            this.PagerClick = function () {
                if (isPlay) { return; }
                isPagerClick = true;

                clearInterval(handid);

                var oPager = $(this), i = parseInt(oPager.text()) - 1;

                if (i != pre) {
                    index = i - 1;
                    self.Play();
                }
            };
        };

//内容2end
//内容3start
$(".content2-ul li").each(function(index){
    $(this).click(function(){
        $(".content2-ul li").removeClass("content2-text-bg");
        $(".content2-ul li").eq(index).addClass("content2-text-bg");
});
});

//内容3end
//内容4购物start
    $(".content3-top-ul li").each(function(index){
        $(this).mouseover(function(){
            $(".content3-top-ul li").removeClass("content3-select");
            $(".content3-top-ul li").eq(index).addClass("content3-select");
        });
          
        $(this).click(function(){
            $(".content3-top-ul li").removeClass("content3-select");
            $(".content3-top-ul li").eq(index).addClass("content3-select");
            $("div.content3-bottom").addClass("disp-off");
            $("div.content3-bottom").removeClass("disp-on");
            $("div.content3-bottom").eq(index).addClass("disp-on");
            $("div.content3-bottom").eq(index).removeClass("disp-off");
        });
    });
//内容4购物end
//内容5Start
 $(".content4-top-ul li").each(function(index){
        $(this).mouseover(function(){
            $(".content4-top-ul li").removeClass("content4-select");
            $(".content4-top-ul li").eq(index).addClass("content4-select");
        });
             $("div.content4-bottom").addClass("disp-off");
            $("div.content4-bottom").eq(0).addClass("disp-on");
        $(this).click(function(){
            $(".content4--top-ul li").removeClass("content4-select");
            $(".content4--top-ul li").eq(index).addClass("content4-select");
            $("div.content4-bottom").addClass("disp-off");
            $("div.content4-bottom").removeClass("disp-on");
            $("div.content4-bottom").eq(index).addClass("disp-on");
            $("div.content4-bottom").eq(index).removeClass("disp-off");
        });
    });
//内容5end

//右边弹出式菜单栏部分start
    $("#moremenu").hide();
    $("#mor").mouseenter(function(){
            $("#moremenu").show(100);
        });
   $("#moremenu").mouseleave(function(){
    $("#moremenu").hide();
}); 
//右边菜单栏弹出部分end
 });//last impotant!
