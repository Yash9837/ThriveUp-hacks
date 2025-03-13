//
//  CollegeFeedViewController.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 11/03/25.
//
import UIKit

class CollegeFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView()
        private let filterScrollView = UIScrollView()
        private let filterStackView = UIStackView()
        private let floatingButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "plus"), for: .normal)
            button.tintColor = .white
            button.backgroundColor = .systemOrange

            button.layer.cornerRadius = 30
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.3
            button.layer.shadowOffset = CGSize(width: 0, height: 4)
            button.addTarget(self, action: #selector(openPostCreationScreen), for: .touchUpInside)
            return button
        }()
    
    private let categories = ["All", "Campus Life", "Buy/Sell", "Marketplace", "Lost & Found", "Events"]
    private var selectedCategory = "All"
    
    
    private var posts: [Post] = [
        Post(username: "Alex", category: "Campus Life", content: "Anyone up for a football match this weekend?",image: UIImage(named: "football") ?? UIImage(systemName: "photo")!, upvotes: 120, comments: 34),
        Post(username: "Riya", category: "Buy/Sell", content: "Selling my cycle. DM for details!", image: UIImage(named: "cycle") ?? UIImage(systemName: "photo")!, upvotes: 85, comments: 19),
        Post(username: "Rahul", category: "Events", content: "Tech Fest registrations are open now! 🎉", image: UIImage(named: "techfest") ?? UIImage(systemName: "photo")!, upvotes: 210, comments: 55),
        Post(username: "Sneha", category: "Lost & Found", content: "Lost my wallet near the library. Please help!", image: UIImage(named: "wallet") ?? UIImage(systemName: "photo")!, upvotes: 67, comments: 12),
        Post(username: "Amit", category: "Marketplace", content: "Selling MacBook Air 2020, lightly used. PM for price.", image: UIImage(named: "macbook") ?? UIImage(systemName: "photo")!, upvotes: 95, comments: 21),
        Post(username: "Neha", category: "Campus Life", content: "New cafeteria menu is amazing! Have you tried it yet?", image: UIImage(named: "cafeteria") ?? UIImage(systemName: "photo")!, upvotes: 180, comments: 42),
        Post(username: "Vikas", category: "Buy/Sell", content: "Looking to buy a second-hand printer. DM if available!", image: UIImage(named: "printer") ?? UIImage(systemName: "photo")!, upvotes: 50, comments: 10),
        Post(username: "Priya", category: "Lost & Found", content: "Found an iPhone near the library. Describe to claim!", image: UIImage(named: "iphone") ?? UIImage(systemName: "photo")!, upvotes: 110, comments: 23),
        Post(username: "Anjali", category: "Events", content: "Dance auditions happening this Saturday!", image: UIImage(named: "dance") ?? UIImage(systemName: "photo")!, upvotes: 190, comments: 39),
        Post(username: "Manoj", category: "Marketplace", content: "Selling gaming chair in good condition. Reasonable price.", image: UIImage(named: "chair") ?? UIImage(systemName: "photo")!, upvotes: 75, comments: 17)
    ]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Campus Feed"
        // Configure scrollable category buttons
               filterScrollView.showsHorizontalScrollIndicator = false
               filterStackView.axis = .horizontal
               filterStackView.alignment = .fill
               filterStackView.spacing = 15
       
        for category in categories {
                    let button = UIButton(type: .system)
                    button.setTitle(category, for: .normal)
                    button.setTitleColor(.white, for: .normal)
                    button.backgroundColor = category == selectedCategory ? .orange : .gray
                    button.layer.cornerRadius = 10
                    button.addTarget(self, action: #selector(filterSelected(_:)), for: .touchUpInside)
                    filterStackView.addArrangedSubview(button)
                }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")
        tableView.separatorStyle = .none
        
        filterScrollView.addSubview(filterStackView)
                view.addSubview(filterScrollView)
                view.addSubview(tableView)
                view.addSubview(floatingButton)
        
        filterScrollView.translatesAutoresizingMaskIntoConstraints = false
                filterStackView.translatesAutoresizingMaskIntoConstraints = false
                tableView.translatesAutoresizingMaskIntoConstraints = false
                floatingButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            filterScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            filterScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            filterScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            filterScrollView.heightAnchor.constraint(equalToConstant: 50),
            
            filterStackView.topAnchor.constraint(equalTo: filterScrollView.topAnchor),
            filterStackView.leadingAnchor.constraint(equalTo: filterScrollView.leadingAnchor),
            filterStackView.trailingAnchor.constraint(equalTo: filterScrollView.trailingAnchor),
            filterStackView.bottomAnchor.constraint(equalTo: filterScrollView.bottomAnchor),
            filterStackView.heightAnchor.constraint(equalTo: filterScrollView.heightAnchor),
            
            tableView.topAnchor.constraint(equalTo: filterScrollView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            floatingButton.widthAnchor.constraint(equalToConstant: 60),
            floatingButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func filterSelected(_ sender: UIButton) {
        guard let category = sender.titleLabel?.text else { return }
        selectedCategory = category
        for case let button as UIButton in filterStackView.arrangedSubviews {
            button.backgroundColor = button.titleLabel?.text == selectedCategory ? .orange : .gray
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCategory == "All" ? posts.count : posts.filter { $0.category == selectedCategory }.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        let filteredPosts = selectedCategory == "All" ? posts : posts.filter { $0.category == selectedCategory }
        cell.configure(with: filteredPosts[indexPath.row])
        return cell
    }
    
    @objc private func openPostCreationScreen() {
        let postCreationVC = PostCreationViewController()
        navigationController?.pushViewController(postCreationVC, animated: true)
    }
}


class PostCreationViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Create New Post"
    }
}

struct Post {
    let username: String
    let category: String
    let content: String
    let image: UIImage
    let upvotes: Int
    let comments: Int
}
class PostCell: UITableViewCell {
    
    private let postImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let categoryLabel = UILabel()
    private let contentLabel = UILabel()
    private let upvoteButton = UIButton(type: .system)
    private let commentButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        postImageView.contentMode = .scaleAspectFill
        postImageView.layer.cornerRadius = 10
        postImageView.clipsToBounds = true
        
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        categoryLabel.font = UIFont.systemFont(ofSize: 12)
        categoryLabel.textColor = .gray
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.numberOfLines = 0
        
        upvoteButton.setTitle("⬆︎ 120", for: .normal)
        commentButton.setTitle("💬 34", for: .normal)
        shareButton.setTitle("🔗 Share", for: .normal)
        
        let buttonStack = UIStackView(arrangedSubviews: [upvoteButton, commentButton, shareButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        
        let stack = UIStackView(arrangedSubviews: [postImageView, categoryLabel, usernameLabel, contentLabel, buttonStack])
        stack.axis = .vertical
        stack.spacing = 5
        
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        postImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with post: Post) {
        usernameLabel.text = post.username
        categoryLabel.text = post.category
        contentLabel.text = post.content
        postImageView.image = post.image
        upvoteButton.setTitle("⬆︎ \(post.upvotes)K", for: .normal)
        commentButton.setTitle("💬 \(post.comments)K", for: .normal)
    }
}


#Preview{
    CollegeFeedViewController()
}
