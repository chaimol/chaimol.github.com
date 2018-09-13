//2015.10.28 23:23 科学计算器 版本号1.0
//x存储第一个数字，y存储第二个数字，msk存储运算符,mtk存储y的字符串。
var x = 0;
var y = 0;
var mtk, msk;
var chartBox = document.getElementById("num3");
document.onmousedown = function(e) {
    e.target.style.backgroundColor = "#88bd45"; //按键按下后会改变按键颜色
}
document.onmouseup = function(e) {
    e.target.style.backgroundColor = "#ace466"; //按键松开后会恢复按键颜色
    var main = document.getElementById("main").style.backgroundColor="#c4c8cb";
    // console.log(main);
}

function clearAll() {
    document.getElementById("num3").value = ""; //清除按钮
    x = 0;
    y = 0;
}

function clearOne() { //退格按钮
    var chart = document.getElementById("num3").value;
    if (chart.length = 0) {
        document.getElementById("num3").value = 0;
    } else {
        mtk = y.toString();
        y = parseFloat(mtk.slice(0, mtk.length - 1));
        document.getElementById("num3").value = chart.slice(0, chart.length - 1);
    }
}

function getValue(val) {
    y = y.toString() + val;
    document.getElementById("num3").value += val; //数字键的输入
}

function getValue_2(val) {
    x = parseFloat(y);
    document.getElementById("num3").value += val; //运算符的输入
    msk = val; //msk存储运算符
    y = 0;
}

function getValue_3(val) {
    document.getElementById("num3").value = Math.E; //常数e
    y = Math.E;
}

function getValue_4(val) {
    document.getElementById("num3").value = Math.PI; //常数π
    y = Math.PI;
}

function calc() {
    y = parseFloat(y);
    switch (msk) {
        case "+":
            resu = x + y;
            break;
        case "-":
            "value",
            resu = x - y;
            break;
        case "*":
            resu = x * y;
            break;
        case "/":
            if (y != 0) {
                resu = x / y;
                break;
            } else {
                resu = "除数不能为零";
                break;
            }

        case "sin":
            resu = Math.sin(y); //此处括号内的值为时，先输入数字后输入sin.显示正确结果，如果想先输入sin后输入数字，括号内为y
            break;
        case "cos":
            resu = Math.cos(y);
            break;
        case "tan":
            resu = Math.tan(y);
            break;
        case "log":
            if (y > 0) {
                resu = Math.log(y) / Math.LN10;
                break;
            } else {
                resu = "输入有误";
                break;
            }
            break;
        case "ln":
            if (y > 0) {
                resu = Math.log(y) / Math.E;
                break;
            } else {
                resu = "输入有误";
                break;
            }
            break;
        case "^":
            resu = Math.pow(x, y);
            break;
        case "√":
            if (y > 0) {
                resu = Math.sqrt(y);
                break;
            } else {
                resu = "输入有误"
                break;
            }
        case "1/x":
            resu = 1 / x;
            break;
        default:
            resu = "";
           alert("您的输入有误，请重新输入");
    }
    document.getElementById("num3").value = resu;
    y = resu.toString();
}

document.onkeydown = function (e){
	console.log(e.key);
}