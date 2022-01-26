//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by brubru on 24.01.2022.
//

import UIKit


class TaskListViewController: UITableViewController {
    private let context = StorageManager.shared.persistentContainer.viewContext

    
    private let cellID = "task"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        self.tableView.allowsMultipleSelectionDuringEditing = false
        setupNavigationBar()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        tableView.reloadData()
    }
 
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearence = UINavigationBarAppearance()
        navBarAppearence.configureWithOpaqueBackground()
        navBarAppearence.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearence.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearence.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearence
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearence
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        
    }
    
    @objc private func addNewTask() {
        addNewTaskAlert(with: "New Task", and: "What do you want to do?")
    }
    
    private func fetchData() {
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try context.fetch(fetchRequest)
        } catch {
           print("Faild to fetch data", error)
        }
    }
    

    private func save(_ taskName: String) {
        
        let task = Task(context: context)
        task.name = taskName
        taskList.append(task)
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        StorageManager.shared.saveContext()
        
    }
    
    private func delete(at indexPath: IndexPath) {
        let task = taskList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        context.delete(task)
        StorageManager.shared.saveContext()
    }
    
    
}



extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
    
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    

    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let edit = UIContextualAction(style: .normal, title: "Edit") { action, sourceView, completion in
            let action = self.editPressed(action: action, sourceView: sourceView, and: indexPath)
            completion(action)
        }
        edit.backgroundColor = .green
        edit.image = UIImage(systemName: "square.and.pencil")

        
        
        let delete = UIContextualAction(style: .normal, title: "Delete") { action, sourceView, completion in
            let delete = self.deletePressed(action: action, sourceView: sourceView, and: indexPath)
            completion(delete)
        }
        delete.backgroundColor = .red
        delete.image = UIImage(systemName: "trash.fill")
        

        let swipeAction = UISwipeActionsConfiguration(actions: [delete, edit])
        return swipeAction
        }

    func editPressed(action: UIContextualAction, sourceView: UIView, and indexPath: IndexPath) -> Bool {
        editTaskAlert(with: "Edit", and: "Do you want to edit yours task?", and: indexPath)
        return true
    }

    func deletePressed(action: UIContextualAction, sourceView: UIView, and indexPath: IndexPath) -> Bool {
        deleteTaskAction(with: "DELETE", and: "Move to trash?", and: indexPath)
        return true
    }
    
    
    
    
    
//MARK: - Alert methods

private func addNewTaskAlert(with title: String, and message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
        guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
        self.save(task)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    alert.addTextField { textField in
        textField.placeholder = "New Task"
    }
    present(alert, animated: true)
}
    
    
    
    private func editTaskAlert(with title: String, and message: String, and indexPath: IndexPath){
        let taskText = taskList[indexPath.row]
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
            guard let task = alert.textFields?.first?.text else { return }
            taskText.name = task
            self.tableView.reloadData()
            StorageManager.shared.saveContext()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
    
        
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.text = taskText.name
            
        }
        present(alert, animated: true)
    }
    
    
    
    private func deleteTaskAction(with title: String, and message: String, and indexPath: IndexPath) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.delete(at: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    
}
