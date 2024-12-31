/**
 * Class for a setting component with a heading, description and switch.
 *
 * Copyright (C) 2024 Scribe
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import UIKit

final class InfoChildTableViewCell: UITableViewCell {

  // MARK: Constants

  static let reuseIdentifier = String(describing: InfoChildTableViewCell.self)

  // MARK: Properties

  @IBOutlet var titleLabelPhone: UILabel!
  @IBOutlet var titleLabelPad: UILabel!
  var titleLabel: UILabel!

  @IBOutlet var subLabelPhone: UILabel!
  @IBOutlet var subLabelPad: UILabel!
  var subLabel: UILabel!

  @IBOutlet var iconImageViewPhone: UIImageView!
  @IBOutlet var iconImageViewPad: UIImageView!
  var iconImageView: UIImageView!

  @IBOutlet var toggleSwitchPhone: UISwitch!
  @IBOutlet var toggleSwitchPad: UISwitch!
  var toggleSwitch: UISwitch!

  @IBOutlet var descriptionLabelPhone: UILabel!
  @IBOutlet var descriptionLabelPad: UILabel!
  var descriptionLabel: UILabel!

  var section: Section?
  var parentSection: Section?

  func setTableView() {
    if DeviceType.isPad {
      titleLabel = titleLabelPad
      subLabel = subLabelPad
      iconImageView = iconImageViewPad
      toggleSwitch = toggleSwitchPad
      descriptionLabel = descriptionLabelPad

      titleLabelPhone.removeFromSuperview()
      subLabelPhone.removeFromSuperview()
      iconImageViewPhone.removeFromSuperview()
      toggleSwitchPhone.removeFromSuperview()
      descriptionLabelPhone.removeFromSuperview()
    } else {
      titleLabel = titleLabelPhone
      subLabel = subLabelPhone
      iconImageView = iconImageViewPhone
      toggleSwitch = toggleSwitchPhone
      descriptionLabel = descriptionLabelPhone

      titleLabelPad.removeFromSuperview()
      subLabelPad.removeFromSuperview()
      iconImageViewPad.removeFromSuperview()
      toggleSwitchPad.removeFromSuperview()
      descriptionLabelPad.removeFromSuperview()
    }
  }

  let userDefaults = UserDefaults(suiteName: "group.be.scri.userDefaultsContainer")!

  var languageCode: String {
    guard let parentSection = parentSection,
          case let .specificLang(lang) = parentSection.sectionState else { return "all" }

    return lang
  }

  var togglePurpose: UserInteractiveState {
    guard let section = section,
          case let .none(action) = section.sectionState else { return .none }

    return action
  }

  // MARK: Functions

  func configureCell(for section: Section) {
    self.section = section
    selectionStyle = .none

    setTableView()
    titleLabel.text = section.sectionTitle

    if let shortDescription = section.shortDescription {
      descriptionLabel.text = shortDescription

      contentView.addSubview(descriptionLabel)
    } else {
      descriptionLabel.text = nil
      descriptionLabel.removeFromSuperview()
    }

    if section.hasToggle {
      accessoryType = .none
      toggleSwitch.isHidden = false

      fetchSwitchStateForCell()

      toggleSwitch.onTintColor = .init(ScribeColor.scribeCTA).withAlphaComponent(0.4)
      toggleSwitch.thumbTintColor = toggleSwitch.isOn ? .init(.scribeCTA) : .lightGray
    } else {
      iconImageView.image = UIImage(
        systemName: preferredLanguage.prefix(2) == "ar" ? "chevron.left": "chevron.right"
      )
      iconImageView.tintColor = menuOptionColor
      toggleSwitch.isHidden = true
    }

    if section.sectionState == .translateLang {
      var langTranslateLanguage = "English"
      if let selectedLang = userDefaults.string(forKey: languageCode + "TranslateLanguage") {
        langTranslateLanguage = getKeyInDict(givenValue: selectedLang, dict: languagesAbbrDict)
      } else {
        userDefaults.set("en", forKey: languageCode + "TranslateLanguage")
      }
      let currentLang = "app._global." + langTranslateLanguage.lowercased()
      subLabel.text = NSLocalizedString(currentLang, value: langTranslateLanguage, comment: "")
      subLabel.textColor = menuOptionColor
    } else {
      subLabel.removeFromSuperview()
    }
  }

  @IBAction func switchDidChange(_: UISwitch) {
    switch togglePurpose {
    case .toggleCommaAndPeriod:
      let dictionaryKey = languageCode + "CommaAndPeriod"
      userDefaults.setValue(toggleSwitch.isOn, forKey: dictionaryKey)

    case .toggleAccentCharacters:
      let dictionaryKey = languageCode + "AccentCharacters"
      userDefaults.setValue(toggleSwitch.isOn, forKey: dictionaryKey)

    case .doubleSpacePeriods:
      let dictionaryKey = languageCode + "DoubleSpacePeriods"
      userDefaults.setValue(toggleSwitch.isOn, forKey: dictionaryKey)

    case .autosuggestEmojis:
      let dictionaryKey = languageCode + "EmojiAutosuggest"
      userDefaults.setValue(toggleSwitch.isOn, forKey: dictionaryKey)

    case .none: break
    }

    toggleSwitch.thumbTintColor = toggleSwitch.isOn ? .init(.scribeCTA) : .lightGray
  }

  func fetchSwitchStateForCell() {
    switch togglePurpose {
    case .toggleCommaAndPeriod:
      let dictionaryKey = languageCode + "CommaAndPeriod"
      if let toggleValue = userDefaults.object(forKey: dictionaryKey) as? Bool {
        toggleSwitch.isOn = toggleValue
      } else {
        toggleSwitch.isOn = false  // Default value
      }

    case .toggleAccentCharacters:
      let dictionaryKey = languageCode + "AccentCharacters"
      if let toggleValue = userDefaults.object(forKey: dictionaryKey) as? Bool {
        toggleSwitch.isOn = toggleValue
      } else {
        toggleSwitch.isOn = false  // Default value
      }

    case .doubleSpacePeriods:
      let dictionaryKey = languageCode + "DoubleSpacePeriods"
      if let toggleValue = userDefaults.object(forKey: dictionaryKey) as? Bool {
        toggleSwitch.isOn = toggleValue
      } else {
        toggleSwitch.isOn = true  // Default value
      }

    case .autosuggestEmojis:
      let dictionaryKey = languageCode + "EmojiAutosuggest"
      if let toggleValue = userDefaults.object(forKey: dictionaryKey) as? Bool {
        toggleSwitch.isOn = toggleValue
      } else {
        toggleSwitch.isOn = true  // Default value
      }

    case .none: break
    }
  }
}
