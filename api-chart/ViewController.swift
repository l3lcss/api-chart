//
//  ViewController.swift
//  api-chart
//
//  Created by Admin on 26/3/2562 BE.
//  Copyright © 2562 th.ac.kmutnb.www. All rights reserved.
//

import UIKit
import Charts
import Foundation

class ViewController: UIViewController {
    struct Data : Codable {
        let data_header : Data_header?
        let data_detail : [Data_detail]?
        
        enum CodingKeys: String, CodingKey {
            
            case data_header = "data_header"
            case data_detail = "data_detail"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            data_header = try values.decodeIfPresent(Data_header.self, forKey: .data_header)
            data_detail = try values.decodeIfPresent([Data_detail].self, forKey: .data_detail)
        }
        
    }
    struct Report_source_of_data : Codable {
        let source_of_data_eng : String?
        let source_of_data_th : String?
        
        enum CodingKeys: String, CodingKey {
            
            case source_of_data_eng = "source_of_data_eng"
            case source_of_data_th = "source_of_data_th"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            source_of_data_eng = try values.decodeIfPresent(String.self, forKey: .source_of_data_eng)
            source_of_data_th = try values.decodeIfPresent(String.self, forKey: .source_of_data_th)
        }
        
    }
    struct Result : Codable {
        let timestamp : String?
        let api : String?
        let data : Data?
        
        enum CodingKeys: String, CodingKey {
            
            case timestamp = "timestamp"
            case api = "api"
            case data = "data"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            timestamp = try values.decodeIfPresent(String.self, forKey: .timestamp)
            api = try values.decodeIfPresent(String.self, forKey: .api)
            data = try values.decodeIfPresent(Data.self, forKey: .data)
        }
        
    }
    struct Data_header : Codable {
        let report_name_eng : String?
        let report_name_th : String?
        let report_uoq_name_eng : String?
        let report_uoq_name_th : String?
        let report_source_of_data : [Report_source_of_data]?
        let report_remark : [String]?
        let last_updated : String?
        
        enum CodingKeys: String, CodingKey {
            
            case report_name_eng = "report_name_eng"
            case report_name_th = "report_name_th"
            case report_uoq_name_eng = "report_uoq_name_eng"
            case report_uoq_name_th = "report_uoq_name_th"
            case report_source_of_data = "report_source_of_data"
            case report_remark = "report_remark"
            case last_updated = "last_updated"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            report_name_eng = try values.decodeIfPresent(String.self, forKey: .report_name_eng)
            report_name_th = try values.decodeIfPresent(String.self, forKey: .report_name_th)
            report_uoq_name_eng = try values.decodeIfPresent(String.self, forKey: .report_uoq_name_eng)
            report_uoq_name_th = try values.decodeIfPresent(String.self, forKey: .report_uoq_name_th)
            report_source_of_data = try values.decodeIfPresent([Report_source_of_data].self, forKey: .report_source_of_data)
            report_remark = try values.decodeIfPresent([String].self, forKey: .report_remark)
            last_updated = try values.decodeIfPresent(String.self, forKey: .last_updated)
        }
        
    }
    struct Data_detail : Codable {
        let period : String?
        let rate : String?
        
        enum CodingKeys: String, CodingKey {
            
            case period = "period"
            case rate = "rate"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            period = try values.decodeIfPresent(String.self, forKey: .period)
            rate = try values.decodeIfPresent(String.self, forKey: .rate)
        }
        
    }
    struct Json4Swift_Base : Codable {
        let result : Result?
        
        enum CodingKeys: String, CodingKey {
            
            case result = "result"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            result = try values.decodeIfPresent(Result.self, forKey: .result)
        }
        
    }
    
    
    
    
    var periodStrG: [String] = ["2019-03-01", "2019-03-10"]
    var dataEntries: [ChartDataEntry] = []
    
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var chartData: LineChartView!
    @IBAction func fetchData(_ sender: Any) {
        let todosEndpoint: String = "https://apigw1.bot.or.th/bot/public/Stat-ReferenceRate/v2/DAILY_REF_RATE/?start_period=2019-03-01&end_period=2019-03-10"
        guard let todosURL = URL(string: todosEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        var todosUrlRequest = URLRequest(url: todosURL)
        todosUrlRequest.httpMethod = "GET"
        todosUrlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        todosUrlRequest.setValue("760350e4-af07-47a9-ba40-93b7e15751bb", forHTTPHeaderField: "x-ibm-client-id")
        
        let session = URLSession.shared
        session.dataTask(with: todosUrlRequest) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            do{
                //here dataResponse received from a network request
                do {
                    //here dataResponse received from a network request
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(Json4Swift_Base.self, from:
                        dataResponse) //Decode JSON Response Data
                    let arr = model.result?.data?.data_detail
                    var rateArr: [Double] = []
                    var periodStr: [String] = []
                    for detail in arr! {
                        let rateDou = Double(detail.rate! as String) ?? 0
                        let period = String(detail.period! as String)
                        rateArr.append(rateDou)
                        periodStr.append(period)
                    }
                    self.periodStrG = periodStr
                    self.setChart(periodStr, values: rateArr)
                } catch let parsingError {
                    print("Error", parsingError)
                }
            } catch let parsingError {
                print("Error", parsingError)
            }
            }.resume()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.periodStrG.count > 0 {
            self.footerLabel.text = "\(self.periodStrG[0] ) - \(self.periodStrG[self.periodStrG.count-1] )"
        }
        setChart(["a", "b", "c", "d"], values: [24.0,43.0,56.0,23.0])
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setChart(_ dataPoints: [String], values: [Double]) {
        chartData.noDataText = "No data available!"
        dataEntries = []
        for i in 0..<values.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
        }
        let line1 = LineChartDataSet(values: dataEntries, label: "Units Consumed")
        line1.colors = [NSUIColor.blue]
        line1.mode = .cubicBezier
        line1.cubicIntensity = 0.2
        
        let gradient = getGradientFilling()
        line1.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
        line1.drawFilledEnabled = true
        
        let data = LineChartData()
        data.addDataSet(line1)
        chartData.data = data
        chartData.setScaleEnabled(false)
        chartData.animate(xAxisDuration: 1.5)
        chartData.drawGridBackgroundEnabled = true
        chartData.xAxis.drawAxisLineEnabled = true
        chartData.xAxis.drawGridLinesEnabled = true
        chartData.leftAxis.drawAxisLineEnabled = true
        chartData.leftAxis.drawGridLinesEnabled = true
        chartData.rightAxis.drawAxisLineEnabled = true
        chartData.rightAxis.drawGridLinesEnabled = true
        chartData.legend.enabled = true
        chartData.xAxis.enabled = true
        chartData.leftAxis.enabled = true
        chartData.rightAxis.enabled = true
        chartData.xAxis.drawLabelsEnabled = true
        chartData.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        
    }
    
    private func getGradientFilling() -> CGGradient {
        // Setting fill gradient color
        let coloTop = UIColor(red: 141/255, green: 133/255, blue: 220/255, alpha: 1).cgColor
        let colorBottom = UIColor(red: 230/255, green: 155/255, blue: 210/255, alpha: 1).cgColor
        // Colors of the gradient
        let gradientColors = [coloTop, colorBottom] as CFArray
        // Positioning of the gradient
        let colorLocations: [CGFloat] = [0.7, 0.0]
        // Gradient Object
        return CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)!
    }

}

