//百度图片式瀑布流 2015.11.2 
$(document).ready(function() {
    $(window).on("load", function() {
        imgLocation();
        var dataImg = {
            "data": [{
                "src": "1.jpg",
                "tag":"标签：蓝天白云阳光沙滩"
            }, {
                "src": "2.jpg",
                "tag":"标签：面朝大海 春暖花开"
            }, {
                "src": "3.jpg",
                "tag":"标签：大海见证爱情"
            }, {
                "src": "4.jpg",
                "tag":"标签：后面钓鱼的抢镜"
            }, {
                "src": "5.jpg",
                "tag":"标签：稳稳的幸福" 
            }, {
                "src": "6.jpg",
                "tag":"标签：绣花鞋"
            }, {
                "src": "7.jpg",
                "tag":"标签：手捧花"
            }, {
                "src": "8.jpg",
                "tag":"标签：婚礼现场"
            }, {
                "src": "9.jpg",
                "tag":"标签：礼盒"
            }, {
                "src": "10.jpg",
                "tag":"标签：观礼台"
            }, {
                "src": "11.jpg",
                "tag":"标签：汪峰同款生日蛋糕"
            }, {    
                "src": "12.jpg",
                "tag":"标签：小礼品"
            }, {
                "src": "13.jpg",
                "tag":"标签：怀旧风"
            }, {
                "src": "14.jpg",
                "tag":"标签：婚宴一角"
            }, {
                "src": "15.jpg",
                "tag":"标签：婚宴一角"
            }, {
                "src": "16.jpg",
                "tag":"标签：签到台"
            }, {
                "src": "17.jpg",
                "tag":" 标签：签到台"
            }, {
                "src": "18.jpg",
                "tag":"标签：永结同心 "
            }, {
                "src": "19.jpg",
                "tag":"  标签：新人照片展"
            }, {
                "src": "20.jpg",
                "tag":"标签：路引"
            }, {
                "src": "21.jpg",
                "tag":"标签：欧式风格"
            }, {
                "src": "22.jpg",
                "tag":"标签：餐桌"
            }, {
                "src": "23.jpg",
                "tag":"标签：请柬"
            }, {
                "src": "24.jpg",
                "tag":"标签：庆典现场"
            }, {
                "src": "25.jpg",
                "tag":"标签：庆典现场"
            }, {
                "src": "26.jpg",
                "tag":" 标签：路引牌"
            }, {
                "src": "27.jpg",
                "tag":"标签：路引"
            }, {
                "src": "28.jpg",
                "tag":"标签：庆典现场"
            }, {
                "src": "29.jpg",
                "tag":"标签：等待另一半的到来"
            }, {
                "src": "30.jpg",
                "tag":"标签：餐桌"
            }, {
                "src": "31.jpg",
                "tag":"标签：现场"
            }, {
                "src": "32.jpg",
                "tag":"标签：鲜花"
            }, {
                "src": "33.jpg",
                "tag":"标签：舞台"
            }, {
                "src": "34.jpg",
                "tag":"标签：T台"
            }, {
                "src": "35.jpg",
                "tag":"标签：沙滩、海洋"
            }, {
                "src": "36.jpg",
                "tag":"标签：小礼品"
            }, {
                "src": "37.jpg",
                "tag":"标签：小礼品"
            }, {
                "src": "38.jpg",
                "tag":"标签：永远的幸福"
            }, {
                "src": "39.jpg",
                "tag":"标签：甜蜜、幸福"
            }, {
                "src": "40.jpg",
                "tag":"标签：甜蜜、幸福"
            }]
        };

        $(window).scroll(function(){
            if (scrollside()) {
                    $.each(dataImg.data, function(index, value) {
                    var box = $("<div>").addClass("box").appendTo($("#container"));
                    var content = $("<div>").addClass("content").appendTo(box);
                    $("<img>").attr("src", "image/" + $(value).attr("src")).appendTo(content);
                    $("<span>").text($(value).attr("tag")).appendTo(content);
                })
                imgLocation();
              
            }

        });
    });
});

function scrollside() {
        var documentHeight = $(document).height();
        var windowHeight= $(window).height();
        var scrollHeght=$(window).scrollTop();
        return (windowHeight+scrollHeght>=documentHeight)?true:false;
    

 }



function imgLocation() {
    var box = $(".box");
    var boxWidth = box.eq(0).width();
    var num = Math.floor($(window).width() / boxWidth);
    var boxArr = [];
    box.each(function(index, value) {
        var boxHeight = box.eq(index).height();
        if (index < num) {
            boxArr[index] = boxHeight + 40;
        } else {
            var minboxHeight = Math.min.apply(null, boxArr);
            //console.log(minboxHeight);
            var minboxIndex = $.inArray(minboxHeight, boxArr);
            $(value).css({
                "position": "absolute",
                "top": minboxHeight,
                "left": box.eq(minboxIndex).position().left

            });
            boxArr[minboxIndex] += box.eq(index).height();
        }
    });
}
