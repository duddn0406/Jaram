import UIKit

class AddHabitViewController: UIViewController {

    var existingHabit: Habit?
    var indexToEdit: Int?

    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "습관 이름 입력"
        tf.borderStyle = .roundedRect
        return tf
    }()

    private let colorWell: UIColorWell = {
        let cw = UIColorWell()
        cw.selectedColor = .systemBlue
        return cw
    }()

    private let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        return picker
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "습관 추가"

        if indexToEdit != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "삭제",
                style: .plain,
                target: self,
                action: #selector(didTapDelete)
            )
            navigationItem.rightBarButtonItem?.tintColor = .systemRed
        }

        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)

        [nameTextField, colorWell, timePicker, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        if let habit = existingHabit {
            nameTextField.text = habit.name
            colorWell.selectedColor = UIColor(hex: habit.colorHex)
            timePicker.date = habit.reminderTime
        }

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            colorWell.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            colorWell.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorWell.heightAnchor.constraint(equalToConstant: 40),
            colorWell.widthAnchor.constraint(equalToConstant: 80),

            timePicker.topAnchor.constraint(equalTo: colorWell.bottomAnchor, constant: 30),
            timePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            saveButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 40),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc func didTapSave() {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        let color = colorWell.selectedColor ?? .systemBlue
        let time = timePicker.date

        var habits = HabitStorage.shared.load()

        if let index = indexToEdit {
            habits[index] = Habit(
                id: habits[index].id,
                name: name,
                colorHex: color.toHexString(),
                reminderTime: time,
                checkedDates: habits[index].checkedDates
            )
        } else {
            let newHabit = Habit(
                id: UUID(),
                name: name,
                colorHex: color.toHexString(),
                reminderTime: time,
                checkedDates: []
            )
            habits.append(newHabit)
        }

        HabitStorage.shared.save(habits)
        dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name("HabitListUpdated"), object: nil)
        }
    }

    @objc func didTapDelete() {
        let alert = UIAlertController(
            title: "삭제 확인",
            message: "이 습관을 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            guard let index = self.indexToEdit else { return }
            var habits = HabitStorage.shared.load()
            guard index < habits.count else { return }
            habits.remove(at: index)
            HabitStorage.shared.save(habits)
            NotificationCenter.default.post(name: Notification.Name("HabitListUpdated"), object: nil)
            self.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }
}
