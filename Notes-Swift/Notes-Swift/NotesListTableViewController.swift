//
//  NotesListTableViewController.swift
//  Notes-Swift
//
//  Created by Aayush Maheshwari on 04/20/19.
//  Copyright (c) 2019 aayush. All rights reserved.
//

import UIKit
import  CoreData
import MapKit

class NotesListTableViewController: UITableViewController{
    let searchController  = UISearchController(searchResultsController: nil)
    var notes: [Note] = []
    var lastIndex = Int(0)
    var filteredNotes : [Note] = []
    var lastoperationAddn = Bool()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search notes"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        do {
            try self.fetchedNotesVC.performFetch()
            fetchedNotesVC.delegate = self
            print("COUNT Fetched First : \(self.fetchedNotesVC.sections?.first?.numberOfObjects ?? 0)")
        } catch let error {
            print("Error : \(error)")
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        DispatchQueue.main.async{
            self.loadNotes()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("view will dissappear entered")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let context  = (UIApplication.shared.delegate as! AppDelegate?)?.persistentContainer.viewContext
        print("Number of sections are \(fetchedNotesVC.sections?.count ?? 0)")
        if (lastoperationAddn){
            if let Notes = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context!) as? Notes {
                    Notes.content = notes[lastIndex].content
                    Notes.title = notes[lastIndex].title
                    Notes.longitude = notes[lastIndex].longitude
                    Notes.latitude = notes[lastIndex].latitude
                do{
                    try context?.save()
                } catch let error{
                    print(error)
                }
                //deliveryEntity.mediaURL = mediaDictionary?["m"] as? String
            }
        }
        else if(notes.count>0)
        {
            if let notetoupdate = fetchedNotesVC.object(at: IndexPath(row : lastIndex , section : 0)) as? Notes
            {
                notetoupdate.content = notes[lastIndex].content
                notetoupdate.title = notes[lastIndex].title
                notetoupdate.longitude = notes[lastIndex].longitude
                notetoupdate.latitude = notes[lastIndex].latitude
                do {
                    try context?.save()
                } catch let error{
                    print(error)
                }
            }
        }
    }
    
    lazy var fetchedNotesVC : NSFetchedResultsController<NSFetchRequestResult> = {
        let context = (UIApplication.shared.delegate as! AppDelegate?)?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:String(describing: Notes.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context!, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()
    
    func loadNotes(){
        guard let numberofNotes = fetchedNotesVC.sections?.first?.numberOfObjects
            else {return}
        notes.removeAll()
        for i in 0..<numberofNotes{
            if let currentnote = fetchedNotesVC.object(at: IndexPath(row : i , section : 0)) as? Notes{
                let note = Note()
                note.content = currentnote.content
                note.title = currentnote.title
                notes.append(note)
            }
        }
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "showNote" {
            let noteDetailViewController = segue.destination as! NoteDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow
            if isFiltering(){
                noteDetailViewController.note = filteredNotes[selectedIndexPath!.row]
                for i in 0..<notes.count {
                    if notes[i].title == filteredNotes[selectedIndexPath!.row].title && notes[i].content == filteredNotes[selectedIndexPath!.row].content
                    {
                        lastIndex = i
                        break
                    }
                }
            } else {
                noteDetailViewController.note = notes[selectedIndexPath!.row]
                lastIndex = selectedIndexPath!.row
            }
            lastoperationAddn = false
        } else if segue.identifier! == "addNote" {
            let note = Note()
            notes.append(note)
            let noteDetailViewController = segue.destination as! NoteDetailViewController
            noteDetailViewController.note = note
            lastIndex = notes.count-1
            lastoperationAddn = true
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if isFiltering() {
            return filteredNotes.count
        }
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell", for: indexPath as IndexPath) as UITableViewCell
        if isFiltering() {
            cell.textLabel!.text = filteredNotes[indexPath.row].title
        } else {
            cell.textLabel!.text = notes[indexPath.row].title
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            var indextoremove = IndexPath(row: indexPath.row, section: indexPath.section)
            if isFiltering(){
                for i in 0..<notes.count {
                    if notes[i].title == filteredNotes[indexPath.row].title && notes[i].content == filteredNotes[indexPath.row].content
                    {
                        indextoremove.row = i
                        filteredNotes.remove(at: indexPath.row)
                        break
                    }
                }
            }
            notes.remove(at: indextoremove.row)
            if isFiltering(){
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }
            else {
                tableView.deleteRows(at: [indextoremove], with: UITableView.RowAnimation.automatic)
            }
            let context = (UIApplication.shared.delegate as! AppDelegate?)?.persistentContainer.viewContext
            //context?.delete()
            if let notetodelete = fetchedNotesVC.object(at: IndexPath(row : indextoremove.row , section : 0)) as? Notes
            {
                context?.delete(notetodelete)
                do {
                    try context?.save()
                } catch let error{
                    print(error)
                }
            }
        default:
            break
        }
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredNotes = notes.filter{($0.content.lowercased().contains(searchText.lowercased()))}
        self.tableView.reloadData()
    }

    
}

extension NotesListTableViewController : NSFetchedResultsControllerDelegate{
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?){
       
    }
}


extension NotesListTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
