// anywhere hao123首页的控制页
$(document).ready(function() {
    $(".panel-heading").each(function(i) {
        $(".panel-heading").eq(i).on("click", function() {
            $(".panel-body").eq(i).slideToggle(300);
        });
    });
    $("#toggle").on("click",function(){
    	$(".panel-body").slideToggle(800);
    });

});
