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
        overrideUserInterfaceStyle = .light // Игнорирование тёмной темы системы
        searchBar.delegate = self
        searchBar.searchTextField.textColor = .white // Текст searchBar становится белым
        iconImage.isHidden = true
    }
}

/*!
    Расширение класса ViewController при помощи UISearchBarDelegate
*/
extension ViewController: UISearchBarDelegate {
    
    /*!
        Функция searchBarSearchButtonClicked реализующая всю основную работу приложения
        \param searchBar
    */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Функция убирающая софтверную клаву после ввода
        
        let urlString = "https://api.weatherapi.com/v1/current.json?key=2879fee53e4b4e52bbd62501232802&q=\(searchBar.text!.replacingOccurrences(of: " ", with: "%20"))&aqi=no" // Наш основной URL в виде JSON
        let url = URL(string: urlString)
        
        var locationName: String? // Название города
        var temperature: Double? // Температура
        var statusWeather: String? // Статус погоды
        var iconWeather: String? // Иконка погоды
        var errorHasOccured: Bool = false // Переменная на случай ошибки запроса
        
        let task = URLSession.shared.dataTask(with: url!) {[weak self] (data, response, error) in
            print(url!) // Для проверки вывод запрашиваемого URL
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                
                // Проверяем JSON на наличие ошибки
                if let _ = json["error"] {
                    errorHasOccured = true
                }
                // Если нет, то находим нужные данные
                else {
                    // Если переменная location соответсьвует JSON элемену location
                    if let location = json["location"] {
                        locationName = location["name"] as? String // Присвоить JSON данные переменной location
                    }
                    
                    // Если переменная current соответсьвует JSON элемену current
                    if let current = json["current"] {
                        temperature = current["temp_c"] as? Double // Присвоить JSON данные temp_c переменной temperature
                        
                        // Если переменная conditionObject соответсьвует JSON элемену condition
                        if let conditionObject = current["condition"] as? AnyObject {
                            statusWeather = conditionObject["text"] as? String // Присвоить JSON данные text переменной statusWeather
                            iconWeather = conditionObject["icon"] as? String // Присвоить JSON данные icon переменной iconWeather
                        }
                    }
                    print("https:" + iconWeather!) // Для проверки
                    print(statusWeather!) // Для проверки
                }
                
                DispatchQueue.main.async {
                    // Работа программы на случай ошибочного запроса
                    if errorHasOccured {
                        self?.cityLabel.text = "City not found" // Вывод ошибки в названии города
                        self?.temperatureLable.isHidden = true
                        self?.iconImage.isHidden = true
                    }
                    // Работа программы на случай если запрос прошёл успешно
                    else {
                        var tempRound: Int
                        tempRound = lround(temperature!) // Округление значений температуры
                        
                        let completeURLIcon = "https:" + iconWeather!
                        let URLIcon = URL(string: completeURLIcon)
                    
                        /*!
                            Делает URL иконки
                            \param from URLIcon: URL, completion: клоужер escaping с param Data?, URLResponse?, Error?
                        */
                        func getData(from URLIcon: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
                            URLSession.shared.dataTask(with: URLIcon, completionHandler: completion).resume()
                        }
                        
                        /*!
                            Скачивание иконки с помощью URL
                            \param from URLIcon: URL
                        */
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
            // Ловит ошибку
            catch let jsonError {
                print(jsonError)
            }
        }
        // Результат работы функции searchBarSearchButtonClicked
        task.resume()
    }
}
