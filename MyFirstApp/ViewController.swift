//
//  ViewController.swift
//  MyFirstApp
//
//  Created by Хто Я on 03.10.2022.
//

import UIKit

class ViewController: UIViewController {

    // Подключённые графические элементы
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLable: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light // Игнор тёмной темы системы
        searchBar.delegate = self
        searchBar.searchTextField.textColor = .white // Текст searchBar становится белым
        iconImage.isHidden = true
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Функция убирающая софтверную клаву после ввода
        
        let urlString = "https://api.weatherapi.com/v1/current.json?key=bf9db530eaa1450380b185133220310&q=\(searchBar.text!.replacingOccurrences(of: " ", with: "%20"))&aqi=no" // Наш основной URL в виде JSON
        let url = URL(string: urlString)
        
        var locationName: String?
        var temperature: Double?
        var statusWeather: String?
        var iconWeather: String?
        var errorHasOccured: Bool = false
        
        let task = URLSession.shared.dataTask(with: url!) {[weak self] (data, response, error) in
            print(url!) // Для проверки
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                
                // Проверяем JSON на наличие ошибки
                if let _ = json["error"] {
                    errorHasOccured = true
                }
                // Если нет, то находим нужные данные
                else {
                    if let location = json["location"] {
                        locationName = location["name"] as? String // Данные местоположения
                    }
                    
                    if let current = json["current"] {
                        temperature = current["temp_c"] as? Double // Данные температуры в Цельсия
                        if let conditionObject = current["condition"] as? AnyObject {
                            statusWeather = conditionObject["text"] as? String // Данные статуса погоды
                            iconWeather = conditionObject["icon"] as? String // Ссылка на PNG иконку
                        }
                    }
                    print("https:" + iconWeather!) // Для проверки
                    print(statusWeather!) // Для проверки
                }
                
                DispatchQueue.main.async {
                    if errorHasOccured {
                        self?.cityLabel.text = "Error city" // Вывод ошибки в названии города
                        self?.temperatureLable.isHidden = true
                        self?.iconImage.isHidden = true
                    }
                    else {
                        var tempRound: Int
                        tempRound = lround(temperature!) // Округление значений температуры
                        
                        let completeURLIcon = "https:" + iconWeather!
                        let URLIcon = URL(string: completeURLIcon)
                        // Делает URL иконки
                        func getData(from URLIcon: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
                            URLSession.shared.dataTask(with: URLIcon, completionHandler: completion).resume()
                        }
                        // Скачивание иконки с помощью URL
                        func downloadImage(from URLIcon: URL) {
                            getData(from: URLIcon) { data, response, error in
                                guard let data = data, error == nil else { return }
                                
                                DispatchQueue.main.async() { [weak self] in
                                    self?.iconImage.image = UIImage(data: data)
                                }
                            }
                        }
                        
                        self?.cityLabel.text = locationName // Вывод запрошенного города
                
                        if (tempRound > 0) {
                            self?.temperatureLable.text = "+\(tempRound)°" // Вывод температуры > 0
                        }
                        else {
                            self?.temperatureLable.text = "\(tempRound)°" // Вывод температуры <= 0
                        }
                        
                        downloadImage(from: URLIcon!) // Вывод иконки погоды
                        self?.temperatureLable.isHidden = false
                        self?.iconImage.isHidden = false
                    }
                }
            }
            catch let jsonError {
                print(jsonError)
            }
        }
        task.resume()
    }
}
