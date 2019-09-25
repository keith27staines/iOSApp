import Foundation

/// DateOfBirthPickerViewModel is the ViewModel for the datepicker used to pick the young person's date of birth
class DateOfBirthPickerViewModel {
    let ageLogic: AgeLogic
    let badValueColor : UIColor
    let goodValueColor : UIColor
    let datePickerMode: UIDatePicker.Mode = UIDatePicker.Mode.date
    let backgroundColor = UIColor.white
    let maximumDateOfBirth = Date()
    
    var defaultDateOfBirth: Date { return ageLogic.defaultDateOfBirth() }
    var userAge: Int? { return ageLogic.age }
    
    init(ageLogic: AgeLogic, badValueColor: UIColor, goodValueColor: UIColor) {
        self.ageLogic = ageLogic
        self.badValueColor = badValueColor
        self.goodValueColor = goodValueColor
    }
    
    func configureDatePickerAppearance(_ datePicker: UIDatePicker) {
        datePicker.setDate(defaultDateOfBirth, animated: false)
        datePicker.datePickerMode = datePickerMode
        datePicker.backgroundColor = backgroundColor
        datePicker.maximumDate = maximumDateOfBirth
    }
    
    func configureToolbarAppearance(_ toolbar: UIToolbar) {
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.isUserInteractionEnabled = true
    }
}
