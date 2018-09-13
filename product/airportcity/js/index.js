//index.js
//主页面js

$(document).ready(function() {
    //导航栏操作
    $(".header .find_li").each(function(i) {
        $(this).on("mouseenter", function() {
            $(".nav_two").hide();
            $(".nav_two").eq(i - 1).show();
            if (i == 0) {
                $(".nav_two").hide();
            }
        });

        $(".nav_two").on("mouseleave", function() {
            $(".nav_two").hide();
        });

    });

    //banner自动播放
    // var bannerPlay = setInterval(function() {
    //     $(".piclist").fadeToggle("linear");
    // }, 3000);

    //banner按钮控制
    $(".piclist_a a").each(function(i) {
        $(this).on("click", function() {
            $(".piclist").fadeOut("linear");
            $(".piclist").eq(i).fadeIn("linear");
            $(".piclist_a a").css({
                background: 'url(./image/icon_in_8.png) no-repeat center'
            });
            $(this).css({
                background: 'url(./image/icon_in_7.png) no-repeat center'
            });
        });
        $(this).on("mouseenter", function() {
            $(this).css({
                background: 'url(./image/icon_in_7.png) no-repeat center'
            });
        });
        $(this).on("mouseleave", function() {
            var status = $(".piclist").eq(i).css("display");
            if (status == "none") {
                $(this).css({
                    background: 'url(./image/icon_in_8.png) no-repeat center'
                });
            }
        });
    });
    //控制按钮单击后，暂停三秒后，再重新计时
    // $(".piclist_a a").on("click",function(){
    //   clearInterval(bannerPlay);
    //         setTimeout(function() {
    //             setInterval(function() {
    //                 $(".piclist").fadeToggle("linear");
    //             }, 3000);
    //         }, 3000);
    // });



    //阻止默认a标签的默认跳转事件
    function aPrevent() {
        if (event.preventDefault) {
            event.preventDefault();
        } else {
            event.returnValue = false;
        }
    }



    //公司新闻部分控制按钮
    $("#usuali>a").on("click", function() {
        aChange("#usuali", ".in_news>.list");
    });

    //合作伙伴控制键
    $("#usual2>a").on("click", function() {
        aChange("#usual2", ".in_hzhb>.list");
    });


    //传入要控制的a的父元素，控制的是类.list
    var aChange = function(tag, control) {
        aPrevent(); //阻止默认的跳转事件
        var a_tit = $(tag).children("a"); //获取传入元素的所有子一级的a元素
        $(a_tit).on("click", function() {
            $(a_tit).css({
                'border-bottom': '2px solid #c70012',
                background: 'url(./image/icon_in_2.gif) no-repeat 16px 16px'
            });
            $(this).css({
                'border-bottom': '2px solid #f3f3f3',
                background: 'url(./image/icon_in_1.gif) no-repeat 16px 16px #f3f3f3'
            });
            var a_id = $(this).attr("href"); //获取a元素的href的值，就是对应的id值。用a_id寄存。
            $(control).hide();
            $(a_id).show();
        });
        //mouseenter时，添加背景，mouseleave时判断display，处理背景。
        $(a_tit).on("mouseenter", function() {
            $(this).css({
                'border-bottom': '2px solid #f3f3f3',
                background: 'url(./image/icon_in_1.gif) no-repeat 16px 16px #f3f3f3'
            });
        });
        $(a_tit).on("mouseleave", function() {
            var a_id = $(this).attr("href");
            var status = $(a_id).css("display");
            if (status == "none") {
                $(this).css({
                    'border-bottom': '2px solid #c70012',
                    background: 'url(./image/icon_in_2.gif) no-repeat 16px 16px'
                });
            };
        });
    }

    //页面滚动时，距离顶部小于30px时，固定到顶部的fix的header2消失，返回顶部按钮消失。否则就出现。
    $(window).scroll(function() {
        if (document.body.scrollTop < 30) {
            $(".header2").hide();
            $(".top3").hide(); //返回顶部
        } else {
            $(".header2").show();
            $(".top3").show();
        }
    });

    //返回顶部按钮
    $(".top3").on("click", function() {
        aPrevent();
        setTimeout(function() {
            document.body.scrollTop = 0;
        }, 200);
    });

    //固定导航栏效果
    $(".header2 .find_li").each(function(i) {
        $(this).on("mouseenter", function() {
            $(".nav_two").hide();
            $(".nav_two").eq(i + 4).show();
            if (i == 0) {
                $(".nav_two").hide();
            }
        });
        $(".nav_two").on("mouseleave", function() {
            $(".nav_two").hide();
        });

    });

    //轮播图
    var mySwiper = new Swiper('.swiper-container1', {
        autoplay: 3000, //3s自动滑动
        prevButton: '.an_r', //前进按钮
        nextButton: '.an_l', //后退按钮
        loop: false, //环路播放
        wrapperClass: 'swiper-wrapper1', //所有图片的容器名称
        slideClass: 'swiper-slide1', //滑动件的名称
        //slideDuplicateClass : 'swiper-slide1',  //loop模式下被复制的滑动件的名称
        slidesPerView: "auto", //slide容器同时显示的slide数量
        loopAdditionalSlides: 8,
        loopedSlides: 8,
        slidesPerGroup: 4, //一次可以跳转的slide的个数
        keyboardControl: true, //键盘控制页面滑动 < >
    });



    //************************************分割线***子页面***************************************************

    //控制iframe的页面高度
    function setIframeHeight(id) {
        var ifrm = document.getElementById(id);
        var doc = ifrm.contentDocument ? ifrm.contentDocument :
            ifrm.contentWindow.document;
        ifrm.style.visibility = 'hidden';
        ifrm.style.height = "10px"; // reset to minimal height ... 
        ifrm.style.height = getDocHeight(doc) + 4 + "px";
        ifrm.style.visibility = 'visible';
    }

    function getDocHeight(doc) {
        doc = doc || document;
        var body = doc.body,
            html = doc.documentElement;
        var height = Math.max(body.scrollHeight, body.offsetHeight,
            html.clientHeight, html.scrollHeight, html.offsetHeight);
        return height;
    }
    //setIframeHeight("inner_if");


  
    //***********************************************************************
//获取用户跳转到的目标地址的href,获取到目标页面的地址，控值按钮图标的显示
$(function(){
    var hrf = window.location.href;             //获取目标的网址
    var endP = hrf.lastIndexOf(".");               //获取网址最后出现的.
    var startP  = hrf.lastIndexOf("/")+1;          //获取网址最后出现的/  位置并+1
    var address = hrf.substring(startP,endP);       //截取两者之间的字符，即为目标字符串。
    var control =[];
    switch (address) {
        case "index":
            control= [0,0];
            break;
        case "gsjs":
            control = [1,1];
            break;
        case "gltd":
            control = [1,2];
            break;
        case "dsj":
            control = [1,3];
            break;
        case "shzr":
            control = [1,4];
            break;
        case "lxwm":
            control = [1,5];
            break;
        case "aclp":
            control = [2,1];
            break;
        case "gnq":
            control =[2,2];
            break;
        case "hykh":
            control = [2,3];
            break;
        case "zlfw":
            control = [3,1];
            break;
        case "wyfw":
            control = [3,2];
            break;
        case "zxgl":
            control = [3,3];
            break;
        case "jjfa":
            control = [3,4];
            break;
        case "yjfk":
            control = [3,5];
            break;
        case "xzzq":
            control = [3,6];
            break;
        case "gsxw":
            control = [4,1];
            break;
        case "gddt":
            control = [4,2];
            break;
        case "hysd":
            control = [4,3];
            break;
        case "mtdt":
            control = [4,4];
            break;
        case "hgrfc":
            control = [5,1];
            break;
        case "rcln":
            control = [5,2];
            break;
        case "shzp":
            control = [5,3];
            break;
        default:
            control = [0,0];

    }
    console.log(control);

});
    


























});
