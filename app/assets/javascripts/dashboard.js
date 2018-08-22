'use strict';
$(document).on('page:load', function() {

    /********************************************
     *               BTC Card                    *
     ********************************************/
        //Get the context of the Chart canvas element we want to select
    var btcChartjs = document.getElementById("btc-chartjs").getContext("2d");
    // Create Linear Gradient
    var blue_trans_gradient = btcChartjs.createLinearGradient(0, 0, 0, 100);
    blue_trans_gradient.addColorStop(0, 'rgba(96,125,139,0.4)');
    blue_trans_gradient.addColorStop(1, 'rgba(255,255,255,0)');
    // Chart Options
    var BTCStats = {
        responsive: true,
        maintainAspectRatio: false,
        datasetStrokeWidth: 3,
        pointDotStrokeWidth: 4,
        tooltipFillColor: "rgba(255, 145, 73,0.8)",
        legend: {
            display: false,
        },
        hover: {
            mode: 'label'
        },
        scales: {
            xAxes: [{
                display: false,
            }],
            yAxes: [{
                display: false,
                ticks: {
                    min: 0,
                    max: 10
                },
                gridLines: {
                    display: false,
                    drawBorder: false
                }
            }]
        },
        title: {
            display: false,
            fontColor: "#FFF",
            fullWidth: false,
            fontSize: 30,
            text: '52%'
        }
    };

    // Chart Data
    var BTCMonthData = {
        labels: new Array(30),
        datasets: [{
            label: "Workers",
            data: new Array(30),
            backgroundColor: blue_trans_gradient,
            borderColor: "#607D8B",
            borderWidth: 1.5,
            strokeColor: "#607D8B",
            pointRadius: 1,
        }]
    };

    var BTCCardconfig = {
        type: 'line',

        // Chart Options
        options: BTCStats,

        // Chart Data
        data: BTCMonthData
    };

    // Create the chart
    var BTCAreaChart = new Chart(btcChartjs, BTCCardconfig);

    window.setInterval(function() {
        // BTCAreaChart.data.labels.push(label);
        BTCAreaChart.data.datasets.forEach((dataset) => {
            dataset.data.shift();
            var n = Math.floor(Math.random()*10) + 1;
            dataset.data.push(n);
        });
        BTCAreaChart.update();
    }, 3000);

/*


    //Get the context of the Chart canvas element we want to select
    var ethChartjs = document.getElementById("eth-chartjs").getContext("2d");
    // Create Linear Gradient
    var blue_trans_gradient = ethChartjs.createLinearGradient(0, 0, 0, 100);
    blue_trans_gradient.addColorStop(0, 'rgba(120, 144, 156,0.4)');
    blue_trans_gradient.addColorStop(1, 'rgba(255,255,255,0)');
    // Chart Options
    var ETHStats = {
        responsive: true,
        maintainAspectRatio: false,
        datasetStrokeWidth: 3,
        pointDotStrokeWidth: 4,
        tooltipFillColor: "rgba(120, 144, 156,0.8)",
        legend: {
            display: false,
        },
        hover: {
            mode: 'label'
        },
        scales: {
            xAxes: [{
                display: false,
            }],
            yAxes: [{
                display: false,
                ticks: {
                    min: 0,
                    max: 85
                },
            }]
        },
        title: {
            display: false,
            fontColor: "#FFF",
            fullWidth: false,
            fontSize: 30,
            text: '52%'
        }
    };

    // Chart Data
    var ETHMonthData = {
        labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul"],
        datasets: [{
            label: "ETH",
            data: [40, 30, 60, 40, 45, 30, 60],
            backgroundColor: blue_trans_gradient,
            borderColor: "#78909C",
            borderWidth: 1.5,
            strokeColor: "#78909C",
            pointRadius: 0,
        }]
    };

    var ETHCardconfig = {
        type: 'line',
        // Chart Options
        options: ETHStats,
        // Chart Data
        data: ETHMonthData
    };

    // Create the chart
    var ETHAreaChart = new Chart(ethChartjs, ETHCardconfig);

    //Get the context of the Chart canvas element we want to select
    var xrpChartjs = document.getElementById("xrp-chartjs").getContext("2d");
    // Create Linear Gradient
    var blue_trans_gradient = xrpChartjs.createLinearGradient(0, 0, 0, 100);
    blue_trans_gradient.addColorStop(0, 'rgba(30,159,242,0.4)');
    blue_trans_gradient.addColorStop(1, 'rgba(255,255,255,0)');
    // Chart Options
    var XRPStats = {
        responsive: true,
        maintainAspectRatio: false,
        datasetStrokeWidth: 3,
        pointDotStrokeWidth: 4,
        tooltipFillColor: "rgba(30,159,242,0.8)",
        legend: {
            display: false,
        },
        hover: {
            mode: 'label'
        },
        scales: {
            xAxes: [{
                display: false,
            }],
            yAxes: [{
                display: false,
                ticks: {
                    min: 0,
                    max: 85
                },
            }]
        },
        title: {
            display: false,
            fontColor: "#FFF",
            fullWidth: false,
            fontSize: 30,
            text: '52%'
        }
    };

    // Chart Data
    var XRPMonthData = {
        labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul"],
        datasets: [{
            label: "XRP",
            data: [70, 20, 35, 60, 20, 40, 30],
            backgroundColor: blue_trans_gradient,
            borderColor: "#1E9FF2",
            borderWidth: 1.5,
            strokeColor: "#1E9FF2",
            pointRadius: 0,
        }]
    };

    var XRPCardconfig = {
        type: 'line',

        // Chart Options
        options: XRPStats,

        // Chart Data
        data: XRPMonthData
    };

    // Create the chart
    var XRPAreaChart = new Chart(xrpChartjs, XRPCardconfig);

*/
})