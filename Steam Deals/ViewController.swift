//
//  ViewController.swift
//  Steam Deals
//
//  Created by Isaac Paschall on 10/13/21.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate {

    // outlets
    @IBOutlet weak var titleFilter: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var storesDropDown: NSPopUpButton!
    @IBOutlet weak var sortByDropDown: NSPopUpButton!
    @IBOutlet weak var maxPriceLabel: NSTextField!
    @IBOutlet weak var maxPriceSlider: NSSlider!
    @IBOutlet weak var metacriticButton: NSButton!
    @IBOutlet weak var titleImage: NSImageView!
    
    // array of deal and score structs
    var deals: [Deal] = []
    var stores: [Store] = []
    
    // set up window constraints
    override func viewWillAppear() {
        super.viewWillAppear()
        self.view.window?.delegate = self
        self.view.window?.minSize = NSSize(width: 100, height: 767)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ...Wait functions make sure one method executes after another
        findStoreWait { (success) -> Void in
            if success {
                searchWait { (success) -> Void in
                    if success {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            // after time to load stores, call initdropdown()
                            self.initDropDown()
                        }
                    }
                }
            }
        }
        
    }
    
    func findStoreWait(completion: (_ success: Bool) -> Void) {
        // first call storeFinder()
        storeFinder()
        // Call completion, when finished, success or faliure
        completion(true)
    }
    func searchWait(completion: (_ success: Bool) -> Void) {
        // second call search()
        search()
        // Call completion, when finished, success or faliure
        completion(true)
    }
    
    @IBAction func metacriticButtonClicked(_ sender: NSButton) {
        // check if selected game has metacritic link
        if let metaLink = deals[tableView.selectedRow].metacriticLink {
            // if yes, open link in default browser
            if let url = URL(string: "https://www.metacritic.com" + metaLink) {
                NSWorkspace.shared.open(url)
            }
        } else {
            // if no, alert user no metacritic link exists
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Error"
                alert.informativeText = "No metacritic Available"
                alert.addButton(withTitle: "Ok")
                alert.runModal()
            }
        }
    }
    
    @IBAction func silderAdjusted(_ sender: NSSlider) {
        //if slider is at max, display 50+
        if sender.integerValue == 50 {
            maxPriceLabel.stringValue = "$50+"
        } else {
            // set slider label to slider value
            maxPriceLabel.stringValue = "$" + String(sender.integerValue)
        }
         
        
    }
    @IBAction func searchButtonClicked(_ sender: NSButton) {
        search()
    }
    
    // searches for games with applied filters
    func search() {
        let session = URLSession.shared
        
        // This is the URL to get information about all spacex cores.
        guard let url = URL(string:urlGenertor()) else { return }
        
        // Prepare a session task that will send a request to the URL, and create a completion handler for the response.
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error as NSError? {
                // There was an error. Report it to the user, and done.
                print("***** Error *****")
                print(error)
                reportError(error: error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                // Something has gone terribly wrong, there was no HTTP response.
                print("unknown response")
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                // The HTTP status code is an error. Report it to the user, and done.
                print("http response code \(httpResponse.statusCode)")
                reportStatus(code: httpResponse.statusCode)
                return
            }
            
            // Unwrap the data object.
            guard let data = data else {
                print("failed to unwrap data?")
                return
            }
            
            // Decode the JSON response.
            let decoder = JSONDecoder()
            
            do {
                self.deals = try decoder.decode([Deal].self, from: data)
            }
            catch {
                print("*** json decode error")
                print(error)
            }
            
            
            DispatchQueue.main.async {
                // Update the UI on the main thread.
                self.tableView.reloadData()
            }
            
        })
        
        // Send the request.
        task.resume()
    }
    
    // generates url with filters applied
    func urlGenertor() -> String {
        // start with url that shows all deals
        var url = "https://www.cheapshark.com/api/1.0/deals?onSale=1"
        
        // check for selected "sort by" option and append to url
        if sortByDropDown.titleOfSelectedItem == "Title" {
            url = url + "&sortBy=Title"
        } else if sortByDropDown.titleOfSelectedItem == "Savings" {
            url = url + "&sortBy=Savings"
        } else if sortByDropDown.titleOfSelectedItem == "Price" {
            url = url + "&sortBy=Price"
        } else if sortByDropDown.titleOfSelectedItem == "Recent" {
            url = url + "&sortBy=recent"
        } else if sortByDropDown.titleOfSelectedItem == "Release" {
            url = url + "&sortBy=Release"
        }
        
        // check for selected "store" option and append to url
        if storesDropDown.titleOfSelectedItem != "All" {
            for i in stores {
                if let name = i.storeName, let id = i.storeID, let active = i.isActive {
                    if storesDropDown.titleOfSelectedItem == name && active == 1 {
                        url = url + "&storeID=" + id
                        break
                    }
                }
            }
        }
        
        // check for "title" option and append to url
        if titleFilter.stringValue != "" {
            url = url + "&title=" + titleFilter.stringValue.replacingOccurrences(of: " ", with: "-")
        }
        
        // check for "max price" option and append to url
        if maxPriceSlider.integerValue != 50 {
            url = url + "&upperPrice=" + String(maxPriceSlider.integerValue)
        }
        
        return url
    }
    
    // puts stores in an array to later check which are available
    func storeFinder() {
        let session = URLSession.shared
        
        // This is the URL to get information about all spacex cores.
        guard let url = URL(string:"https://www.cheapshark.com/api/1.0/stores") else { return }
        
        // Prepare a session task that will send a request to the URL, and create a completion handler for the response.
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error as NSError? {
                // There was an error. Report it to the user, and done.
                print("***** Error *****")
                print(error)
                reportError(error: error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                // Something has gone terribly wrong, there was no HTTP response.
                print("unknown response")
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                // The HTTP status code is an error. Report it to the user, and done.
                print("http response code \(httpResponse.statusCode)")
                reportStatus(code: httpResponse.statusCode)
                return
            }
            
            // Unwrap the data object.
            guard let data = data else {
                print("failed to unwrap data?")
                return
            }
            
            // Decode the JSON response.
            let decoder = JSONDecoder()
            
            do {
                self.stores = try decoder.decode([Store].self, from: data)
            }
            catch {
                print("*** json decode error")
                print(error)
            }
            
        })
        
        // Send the request.
        task.resume()
    }
    
    // checks for available stores and adds them to the store drop down menu
    func initDropDown() {
        for i in stores {
            if let active = i.isActive, let storeName = i.storeName {
                if active == 1 {
                    storesDropDown.addItem(withTitle: storeName)
                }
            }
        }
    }
    
    // given the storeID, this returns the store name
    func findStoreName(storeID: String) -> String {
        for i in stores {
            if let id = i.storeID, let name = i.storeName {
                if id == storeID {
                    return name
                }
            }
        }
        return "N/A"
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return deals.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let deal = deals[row]
        // load store column
        if tableColumn?.identifier.rawValue == "storeColumn" {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "storeCell"), owner: self) as? NSTableCellView {
                if let store = deal.storeID {
                    cell.textField?.stringValue = findStoreName(storeID: store)
                    return cell
                } else {
                    cell.textField?.stringValue = "N/A"
                    return cell
                }
            }
        } else if tableColumn?.identifier.rawValue == "titleColumn"{
            // load title column
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "titleCell"), owner: self) as? NSTableCellView {
                if let title = deal.title {
                    cell.textField?.stringValue = title
                    return cell
                } else {
                    cell.textField?.stringValue = "N/A"
                    return cell
                }
            }
        } else if tableColumn?.identifier.rawValue == "saleColumn"{
            // load sale solumn
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "saleCell"), owner: self) as? NSTableCellView {
                if let sale = deal.salePrice {
                    let saleFormatted = "$" + sale
                    cell.textField?.stringValue = saleFormatted
                    return cell
                } else {
                    cell.textField?.stringValue = "N/A"
                    return cell
                }
            }
        } else if tableColumn?.identifier.rawValue == "originalColumn"{
            // load original column
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "originalCell"), owner: self) as? NSTableCellView {
                if let original = deal.normalPrice {
                    let originalFormatted = "$" + original
                    cell.textField?.stringValue = originalFormatted
                    return cell
                } else {
                    cell.textField?.stringValue = "N/A"
                    return cell
                }
            }
        } else if tableColumn?.identifier.rawValue == "savingColumn"{
            // load savings column
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "savingCell"), owner: self) as? NSTableCellView {
                if let saving = deal.savings {
                    let savingFloat = lround(Double(saving)!)
                    let savingFormatted = String(format: "%i", savingFloat) + "%"
                    cell.textField?.stringValue = savingFormatted
                    return cell
                } else {
                    cell.textField?.stringValue = "N/A"
                    return cell
                }
            }
        } else {
            // load date column
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dateCell"), owner: self) as? NSTableCellView {
                // convert from unix date to month, year
                if let date = deal.releaseDate {
                    let timeResult = date
                    let date1 = Date(timeIntervalSince1970: TimeInterval(timeResult))
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = DateFormatter.Style.none //Set time style
                    dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
                    dateFormatter.timeZone = .current
                    let localDate = dateFormatter.string(from: date1)
                    
                    cell.textField?.stringValue = localDate
                    return cell
                } else {
                    cell.textField?.stringValue = "N/A"
                    return cell
                }
            }
        }
        // should never return nil
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let img = deals[tableView.selectedRow].thumb {
            // Load the image from url
            if let url = URL(string: img) {
                DispatchQueue.global().async {
                    let pic = NSImage(contentsOf: url)
                    DispatchQueue.main.async {
                        self.titleImage.image = pic
                    }
                }
            }
        }
        // show delete button once a row is selected
        metacriticButton.isHidden = false
    }

}

// Report the status code to the user.
// In production, you should provide better info.
func reportStatus(code: Int) {
    DispatchQueue.main.async {
        let alert = NSAlert()
        alert.messageText = "HTTP Status Code \(code)"
        alert.informativeText = "The HTTP server returned an error status code."
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Ok")
        alert.runModal()
    }
}


// Report the error directly to the user.
func reportError(error: NSError) {
    DispatchQueue.main.async {
        let alert = NSAlert(error: error)
        alert.runModal()
    }
}
