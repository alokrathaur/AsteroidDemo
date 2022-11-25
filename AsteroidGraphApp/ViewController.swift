//
//  ViewController.swift
//  AsteroidGraphApp
//
//  Created by ALOK on 24/11/22.
//

import UIKit
import Alamofire
import Charts


class ViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var lbl_asteroidIDValue: UILabel!
    
    @IBOutlet weak var lbl_asteroidMaxSpeed: UILabel!
    
    @IBOutlet weak var lbl_closeAsteroidId: UILabel!
    
    @IBOutlet weak var lbl_closeAsteroidDistance: UILabel!
    
    @IBOutlet weak var lbl_asteroidAvgSize: UILabel!
    
    
    
    @IBOutlet weak var txtStartDatePicker: UITextField!
    @IBOutlet weak var txtEndDatePicker: UITextField!
    
    @IBOutlet weak var barChart: BarChartView!
    
    
   let datePicker = UIDatePicker()

    var asteroidData:SocketMsg?
    
    var asteroidId = [String]()
    var speed = [Double]()
    
    var closeAsteroid = [Double]()
    
    var diameterMax = [Double]()
    var diameterMin = [Double]()
    
    var totalKeys = [String]()
    var totalAsteroids = [Double]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtStartDatePicker.delegate = self;
        txtEndDatePicker.delegate = self;
        
//        showDatePicker();
        self.createDatePicker(forField: txtStartDatePicker)
        self.createDatePicker(forField: txtEndDatePicker)
        graphSetup()
        showGraphData()
        // Do any additional setup after loading the view.
    }
    
    
  
    
    
    @IBAction func submitButtonAction(_ sender: Any) {
        
        if(txtStartDatePicker.text?.count != 0 && txtEndDatePicker.text?.count != 0 )
        {
            nasaAPI();
        }
        
    }
    
    func graphSetup(){
        
        barChart.extraTopOffset = 15
        
        barChart.rightAxis.enabled = false
        
        barChart.xAxis.labelPosition = .bottom
        barChart.xAxis.drawLabelsEnabled = true
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.xAxis.granularity = 1.0
        
        barChart.leftAxis.setLabelCount(11, force: true)
        barChart.leftAxis.axisMinimum = 0.0
        barChart.leftAxis.axisMaximum = 100.0
        barChart.leftAxis.granularity = 1.0
        barChart.leftAxis.drawGridLinesEnabled = false
        
        barChart.zoom(scaleX: 1.0, scaleY: 1.0, x: 0, y: 0)
        
        //        barChart.animate(yAxisDuration: 1.5, easingOption: .linear)
        
    }
    
    func showGraphData(){
        
        barChart.clear()
        
        barChart.animate(yAxisDuration: 1.0, easingOption: .linear)
        barChart.setBarChartData(xValues: self.totalKeys, yValues: self.totalAsteroids, label: "Asteroid ")
       
        
    }
    
    
    func createDatePicker(forField field : UITextField){
        datePicker.datePickerMode = .date

       //ToolBar
       let toolbar = UIToolbar();
       toolbar.sizeToFit()
       let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
          let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
      let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));

     toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)

        field.inputAccessoryView = toolbar
        field.inputView = datePicker

    }
   
    
    var activeTextField: UITextField!

    func textFieldDidBeginEditing(_ textField: UITextField) {
         activeTextField = textField
    }


    @objc func donedatePicker(){

     //2015-09-07
        if activeTextField == txtStartDatePicker {
            // OR with Tag like
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            txtStartDatePicker.text = formatter.string(from: datePicker.date)
            self.view.endEditing(true)
         }
        if activeTextField == txtEndDatePicker {  // OR with Tag like
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            txtEndDatePicker.text = formatter.string(from: datePicker.date)
            self.view.endEditing(true)
         }
        
     self.view.endEditing(true)
   }

   @objc func cancelDatePicker(){
      self.view.endEditing(true)
    }
    
    func average(nums: [Double]) -> Double {

        var total = 0.0
        //use the parameter-array instead of the global variable votes
        for vote in nums{
            total += Double(vote)
        }

        let votesTotal = Double(nums.count)
        var average = total/votesTotal
        return average
    }
    
    func nasaAPI(){
        
        var demoKey = "ipxBXl9Yb28ebDmyhlOqsA9x08CN3XOPg8R400l9";
        let url = "https://api.nasa.gov/neo/rest/v1/feed?"
        
        let parameters: Parameters = [
            "start_date": txtStartDatePicker.text!,
            "end_date": txtEndDatePicker.text!,
            "api_key": demoKey
        ]
        
        SwiftLoader.show(animated: true);
//
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { [self] response in
            print("Alamofire api called");
            print(response.result.value as Any);
            if let result = response.result.value {
                
                //print(response.result)

                switch response.result {
                case .success:
                    if let data = response.data {
                       // print(data)
                        // Convert This in JSON
                        do {
                            
                            self.asteroidData = try JSONDecoder().decode(SocketMsg.self, from: data)
                            print(self.asteroidData);
                            
                            if(self.asteroidData?.near_earth_objects == nil){
                                SwiftLoader.hide();
                                return;
                            }
                            
                        for i in 0...(self.asteroidData?.near_earth_objects?.count ?? 0) {
                            
                            var nearObj = self.asteroidData?.near_earth_objects as [String: [NearEarthObject]];
                            
                            //
                            
                            self.asteroidId.removeAll();
                            self.speed.removeAll();
                            self.closeAsteroid.removeAll();
                            self.totalKeys.removeAll();
                            self.totalAsteroids.removeAll();
                            
                            for (key, value) in nearObj {
                               // print("\(key) -> \(value)")
                                self.totalKeys.append(key);
                                
                                var data = value as! [NearEarthObject]
                                self.totalAsteroids.append(Double(data.count));
                                var closeApproach:[CloseApproachDatum]? = data[i].close_approach_data;
                                //print(closeApproach?[0].relative_velocity?.kilometers_per_hour)
                                
                                for i in data {
                                    
                                    
                                    self.asteroidId.append(i.id ?? "");
                                   
                                    self.speed.append(Double(i.close_approach_data?[0].relative_velocity?.kilometers_per_hour ?? "0") ?? 0);
                                    
                                    self.closeAsteroid.append(Double(i.close_approach_data?[0].miss_distance?.kilometers ?? "0") ?? 0)
                                    
                                    self.diameterMax.append(i.estimated_diameter?.kilometers?.estimated_diameter_max ?? 0);
                                    
                                    self.diameterMin.append(i.estimated_diameter?.kilometers?.estimated_diameter_min ?? 0);
                                    
                                    var avgMax =  self.average(nums: self.diameterMax);
                                    var avgMin =  self.average(nums: self.diameterMin);
                                    var totalAvg:Double = (avgMax+avgMin/2);
                                    
                                    self.lbl_asteroidAvgSize.text = String(totalAvg)
                                    
                                    
                                    
                                    
                                }
                                
                                print(self.asteroidId);
                                print(self.speed);
                                
                                if let maxValue = self.speed.max(), let index = self.speed.index(of: maxValue) {
                                    print("max: \(self.speed.max())")
                                    let desiredValue = asteroidId[index]
                                    print(desiredValue)
                                    //asteroid id
                                    self.lbl_asteroidIDValue.text = desiredValue;
                                    self.lbl_asteroidMaxSpeed.text = String(self.speed.max() ?? 0);
                                    
                                    ///// 4
                                }
                                
                                if let minValue = self.closeAsteroid.min(), let index = self.closeAsteroid.index(of: minValue) {
                                    print("min: \(self.closeAsteroid.min())")
                                    let desiredValue = asteroidId[index]
                                    print(desiredValue)
                                    
                                    self.lbl_closeAsteroidId.text = desiredValue;
                                    self.lbl_closeAsteroidDistance.text = String(self.closeAsteroid.min() ?? 0);
                                    
                                }
                                
                            }
                            
                            print("Total asteroids: \(self.totalAsteroids)");
                            print("Date: \(self.totalKeys)");
                            
                            showGraphData();
                            SwiftLoader.hide();
                            //print(nearObj);
                            
                        }
                            
                        }catch let error as NSError{
                            print(error)
                        }

                    }
                case .failure(let error):
                    print("Error:", error)
                }
                
            }
        }
    }


}


extension BarChartView {
    
    private class BarChartFormatter: NSObject, IAxisValueFormatter {
        
        var labels: [String] = []
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            
              return labels[Int(value) % labels.count]
           // return labels[Int(value)]
        }
        
        init(labels: [String]) {
            super.init()
            self.labels = labels
        }
        
    }
    
    func setBarChartData(xValues: [String], yValues: [Double], label: String) {
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<yValues.count {
         
            let dataEntry = BarChartDataEntry(x: Double(i), y: yValues[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: label)
       // chartDataSet.colors = UIColor.orange
        chartDataSet.valueFont = NSUIFont.systemFont(ofSize: 11)
        chartDataSet.stackLabels = ["No of asteroids", "Date"]
        
        let chartData = BarChartData(dataSet: chartDataSet)
     
        if xValues.count == 1{
            chartData.barWidth = Double(0.15)
        }
        else if (xValues.count == 2 || xValues.count == 3){
            chartData.barWidth = Double(0.3)
        }
        else{
           
            chartData.barWidth = Double(0.4)
            self.zoom(scaleX: 1.0, scaleY: 1.0, x: 0, y: 0)
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 0
        formatter.multiplier = 1.0
        chartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        
//        let chartFormatter = BarChartFormatter(labels: xValues)
        let chartFormatter = DateValueFormatter();
        
        let xAxis = XAxis()
        //xAxis.valueFormatter = //Date(chart: chartView)
        
        xAxis.valueFormatter = DateValueFormatter();
        //self.xAxis.valueFormatter = DateValueFormatter();
        
        self.data = chartData
    }
}

