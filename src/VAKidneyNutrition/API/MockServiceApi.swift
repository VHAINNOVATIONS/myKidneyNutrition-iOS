//
//  MockServiceApi.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Modified by TCCODER on 02/04/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import Foundation
import SwiftyJSON

/// the error messages
let ERROR_RESOURCE_NOT_FOUND = NSLocalizedString("Resource not found", comment: "Resource not found")
let ERROR_ACCOUNT_EXISTS_USERNAME = NSLocalizedString("Account with given username already exists", comment: "Account with given username already exists")
let ERROR_ACCOUNT_EXISTS_EMAIL = NSLocalizedString("Account with given email already exists", comment: "Account with given email already exists")

/// the number of seconds to delay before callback is invoked
let DELAY_FOR_DEMONSTRATION: TimeInterval = 0.5

/**
 * Mock ServiceApi implementation. Provides static data.
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - UI changes support
 */
class MockServiceApi: ServiceApi {

    /// the singleton
    static let shared = MockServiceApi()

    /// in-memory cached states
    private var states: [String]?

    /// in-memory cached cities
    private var allCities: [String]?
    private var citiesByState = [String:[String]]()

    /// flag: true - goals was deleted, false - else
    var goalsDeleted = false

    /// Authenticate using given email and password
    ///
    /// - Parameters:
    ///   - email: the email
    ///   - password: the password
    ///   - callback: the callback to invoke when successfully authenticated and return UserInfo and Profile
    ///   - failure: the callback to invoke when an error occurred
    func authenticate(email: String, password: String, callback: @escaping (UserInfo) -> (), failure: @escaping (String?, String?)->()) {
        if !ValidationUtils.validateStringNotEmpty(email, { error in failure(ERROR_EMPTY_CREDENTIALS, nil) })
            || !ValidationUtils.validateEmail(email, { error in failure(error, nil) })
            || !ValidationUtils.validateStringNotEmpty(password, { error in failure(nil, ERROR_EMPTY_CREDENTIALS) }) {
            return
        }

        if let json = JSON.resource(named: "sampleAccount") {
            let userInfo = UserInfo.fromJson(json)
            if userInfo.email == email && userInfo.password == password {
                AuthenticationUtil.sharedInstance.userInfo = userInfo
                callback(userInfo)
                return
            }
            else if userInfo.email != email {
                failure(ERROR_WRONG_CREDENTIALS, ERROR_WRONG_CREDENTIALS)
            }
            else if userInfo.password != password {
                failure(nil, ERROR_WRONG_CREDENTIALS)
            }
        }

    }

    /// Checks only if the fields are correctly filled and if they do not match to demo account.
    ///
    /// - Parameters:
    ///   - email: the email
    ///   - password: the password
    ///   - confirmPassword: the password from the second field
    ///   - callback: the callback to invoke when success (the new account can be created)
    ///   - failure: the failure callback to return an error
    func checkIfAccountCanBeCreated(email: String, password: String, confirmPassword: String, callback: @escaping (UserInfo) -> (), failure: @escaping FailureCallback) {
        let emptyStringCallback: FailureCallback = { (_) -> () in
            failure(ERROR_WRONG_CREDENTIALS_SIGNUP)
        }
        if !ValidationUtils.validateEmail(email, failure)
            || !ValidationUtils.validateStringNotEmpty(password, emptyStringCallback)
            || !ValidationUtils.validateStringNotEmpty(confirmPassword, emptyStringCallback) {
            return
        }
        else if password != confirmPassword {
            failure(ERROR_PASSWORDS_NOT_MATCH)
            return
        }

        let userInfo = UserInfo(id: UUID().uuidString)
        userInfo.email = email
        userInfo.password = password

        callback(userInfo)
    }

    /// Register account. Just assign random IDs.
    ///
    /// - Parameters:
    ///   - userInfo: the user info
    ///   - profile: the profile
    ///   - failure: the failure callback to return an error
    func register(userInfo: UserInfo, profile: Profile, callback: @escaping (UserInfo) -> (), failure: @escaping FailureCallback) {
        delay(DELAY_FOR_DEMONSTRATION) {
            userInfo.id = UUID().uuidString
            profile.id = UUID().uuidString
            userInfo.isSetupCompleted = true
            callback(userInfo)
        }
    }

    /// Get profile
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getProfile(callback: @escaping (Profile) -> (), failure: @escaping FailureCallback) {
        if let json = JSON.resource(named: "sampleAccount"),
            let currentUser = AuthenticationUtil.sharedInstance.userInfo {
            let userInfo = UserInfo.fromJson(json)
            if userInfo.email == currentUser.email && userInfo.password == currentUser.password {
                let object = Profile.fromJson(json)
                callback(object)
            }
            else {
                failure(NSLocalizedString("Profile not found", comment: "Profile not found"))
            }
        }
    }

    /// Update profile. R->C
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func updateProfile(_ profile: Profile, callback: @escaping () -> (), failure: @escaping FailureCallback) {
        failure("Not supported")
    }

    /// Initiate password reset
    ///
    /// - Parameters:
    ///   - email: the email
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func forgotPassword(email: String, callback: @escaping ()->(), failure: @escaping FailureCallback) {
        if !ValidationUtils.validateEmail(email, failure) {
            return
        }
        delay(DELAY_FOR_DEMONSTRATION) {
            failure("This feature will be implemented in future")
        }
    }

    /// Logout
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func logout(callback: @escaping ()->(), failure: @escaping FailureCallback) {
        goalsDeleted = false
        callback()
    }

    /// Get goals
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getGoals(callback: @escaping ([Goal], [GoalCategory])->(), failure: @escaping FailureCallback) {
        if goalsDeleted {
            callback([], [])
            return
        }
        if let json = JSON.resource(named: "goals") {
            var goals = json.arrayValue.map({Goal.fromJson($0)})
            getCategories(callback: { (categories) in
                MockServiceApi.applyCategories(categories, toGoals: goals)
                var sOrder = 0
                for goal in goals {
                    goal.sOrder = sOrder
                    sOrder += 1
                }
                goals = goals.filter({$0.category != nil})
                callback(goals, categories)
                return
            }, failure: failure)
        }
    }

    /// Save goal
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func saveGoal(goal: Goal, callback: @escaping (Goal)->(), failure: @escaping FailureCallback) {
        failure("Not supported")
    }

    /// Delete goal
    ///
    /// - Parameters:
    ///   - goal: the goal
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func deleteGoal(goal: Goal, callback: @escaping ()->(), failure: @escaping FailureCallback) {
        goalsDeleted = true
        callback()
    }

    class func applyCategories(_ list: [GoalCategory], toGoals goals: [Goal]) {
        let categoriesMap = list.hashmapWithKey({$0.id})
        for goal in goals {
            if let category = categoriesMap[goal.categoryId] {
                goal.category = category
                category.numberOfGoals += 1
            }
        }
    }

    /// Get goal categories
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getCategories(callback: @escaping ([GoalCategory])->(), failure: @escaping FailureCallback) {
        if let json = JSON.resource(named: "goalCategories") {
            let categories = json.arrayValue.map({GoalCategory.fromJson($0)})
            callback(categories)
        }
    }

    /// Get reports
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getReports(callback: @escaping ([Report])->(), failure: @escaping FailureCallback) {
        if let json = JSON.resource(named: "reports") {
            callback(json.arrayValue.map({Report.fromJson($0)}))
            return
        }
    }

    /// Get previous and next reports
    ///
    /// - Parameters:
    ///   - report: the reference report
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getNearbyReports(report: Report, callback: @escaping (Report?, Report?)->(), failure: @escaping FailureCallback) {
        getReports(callback: { (reports) in
            var prev: Report?
            var isCurrentReport = false
            for item in reports {
                if isCurrentReport {
                    callback(prev, item)
                    return
                }
                if item.hashValue == report.hashValue {
                    isCurrentReport = true
                }
                else {
                    prev = item
                }
            }
            if isCurrentReport {
                callback(prev, nil)
            }
            else {
                callback(nil, nil) // the reference report was not found
            }
        }, failure: failure)
    }

    /// Get suggestion for the report
    ///
    ///   - report: the reference report
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getSuggestion(forReport report: Report, callback: @escaping (Suggestion?)->(), failure: @escaping FailureCallback) {
        if report.lastEventDate != nil {
            self.getMainSuggestions(callback: { items in
                callback(items.first)
            }, failure: failure)
        }
        callback(nil)
    }

    /// Get suggestions for Home screen
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getMainSuggestions(callback: @escaping ([Suggestion])->(), failure: @escaping FailureCallback) {
        if let json = JSON.resource(named: "suggestions") {
            let suggestions = json.arrayValue.map({Suggestion.fromJson($0)})
            callback(suggestions)
            return
        }
    }

    /// Get rewards
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getRewards(callback: @escaping ([Reward])->(), failure: @escaping FailureCallback) {
        if let json = JSON.resource(named: "rewards") {
            let items = json.arrayValue.map({Reward.fromJson($0)})
            callback(items)
            return
        }
    }

    /// Get tasks
    ///
    /// - Parameters:
    ///   - category: the category
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getTasks(category: GoalCategory, callback: @escaping ([Task])->(), failure: @escaping FailureCallback) {
        if let json = JSON.resource(named: "tasks") {
            let list = json.arrayValue.filter({$0["categoryId"].stringValue == category.id}).map({$0["title"].stringValue})
            callback(list)
            return
        }
    }

    /// Get tasks details
    ///
    /// - Parameters:
    ///   - task: the task
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getUnits(task: Task, callback: @escaping (TaskUnitLimits, TaskUnitSuffix, TaskExtraData)->(), failure: @escaping FailureCallback) {
        if let json = JSON.resource(named: "tasks"),
            let task = json.arrayValue.filter({$0["title"].stringValue == task}).first {
            let limits: TaskUnitLimits = (task["min"].intValue...task["max"].intValue, task["interval"].intValue)
            let suffixes: TaskUnitSuffix = (task["unit1"].stringValue, task["unitMultiple"].stringValue, task["valueText"].stringValue)
            let extra: TaskExtraData = (task["iconName"].stringValue, UIColor.fromString(task["color"].stringValue) ?? .red)
            callback(limits, suffixes, extra)
            return
        }
        failure("Not found")
    }

    /// Get schedule
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success: (hour, list of medications)
    ///   - failure: the failure callback to return an error
    func getMedicationScheduleForToday(callback: @escaping ([MedicationScheduleItem])->(), failure: @escaping FailureCallback) {
        if let json = JSON.resource(named: "medications") {
            let list = json.arrayValue.map({Medication.fromJson($0)})
            let todayWeekday = Date().getWeekday()
            var hourToListMap = [Int: [(Medication, MedicationTime)]]()
            for medication in list {
                for time in medication.times {
                    if time.weekday == -1 || time.weekday == todayWeekday {
                        var list = hourToListMap[time.hour]
                        if list == nil {
                            list = [(Medication, MedicationTime)]()
                        }
                        list!.append((medication, time))
                        hourToListMap[time.hour] = list
                    }
                }
            }
            var flat = [(Int, [(Medication, MedicationTime)])]()
            for (k,v) in hourToListMap {
                flat.append((k, v))
            }
            flat = flat.sorted(by: {
                if $0.0 < $1.0 {
                    return true
                }
                return false
            })
            callback(flat)
            return
        }
    }

    /// Get medications
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success: (list of medications)
    ///   - failure: the failure callback to return an error
    func getMedicationForToday(callback: @escaping ([Medication])->(), failure: @escaping FailureCallback) {
        if let json = JSON.resource(named: "medications") {
            let list = json.arrayValue.map({Medication.fromJson($0)})
            let todayWeekday = Date().getWeekday()
            var medications = [Medication]()
            for medication in list {
                for time in medication.times {
                    if time.weekday == -1 || time.weekday == todayWeekday {
                        medications.append(medication)
                        break
                    }
                }
            }
            callback(medications)
            return
        }
    }

    /// Get medication resources
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getMedicationResources(callback: @escaping ([(String,[MedicationResource])])->(), failure: @escaping FailureCallback) {
        delay(DELAY_FOR_DEMONSTRATION) {
            if let json = JSON.resource(named: "medicationResources") {
                let items = json.arrayValue.map({($0["title"].stringValue, $0["items"].arrayValue.map({MedicationResource.fromJson($0)}))})
                callback(items)
            }
        }
    }

    /// Get drag resources
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getDragResources(callback: @escaping ([(String,[MedicationResource])])->(), failure: @escaping FailureCallback) {
        delay(DELAY_FOR_DEMONSTRATION) {
            if let json = JSON.resource(named: "dragResources") {
                let items = json.arrayValue.map({($0["title"].stringValue, $0["items"].arrayValue.map({MedicationResource.fromJson($0)}))})
                callback(items)
            }
        }
    }

    /// Get resources.
    /// Uses the same sample JSON file for all `types`.
    ///
    ///   - type: the type
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getResources(type: ResourceType, callback: @escaping ([Resource])->(), failure: @escaping FailureCallback) {
        delay(DELAY_FOR_DEMONSTRATION) {
            if let json = JSON.resource(named: "resources") {
                let items = json.arrayValue.map({Resource.fromJson($0)})
                callback(items)
            }
        }
    }

    /// Get goal form tips
    ///
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getGoalTip(callback: @escaping (JSON)->(), failure: @escaping FailureCallback) {
        if let json = JSON.resource(named: "goalTips") {
            callback(json)
        }
    }

    /// Get food for "Food Intake" screen
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getFood(callback: @escaping ([Food])->(), failure: @escaping FailureCallback) {
        if let json = JSON.resource(named: "food") {
            let list = json.arrayValue.map({Food.fromJson($0)})
            callback(list)
        }
    }

    /// Save food intake
    ///
    /// - Parameters:
    ///   - food: the food to save
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func saveFood(food: Food, callback: @escaping (Food)->(), failure: @escaping FailureCallback) {
        failure("Not supported")
    }

    /// Get Workouts
    ///
    /// - Parameters:
    ///   - callback: the callback to invoke when success
    ///   - failure: the failure callback to return an error
    func getWorkout(callback: @escaping ([Workout])->(), failure: @escaping FailureCallback) {
        if let json = JSON.resource(named: "workouts") {
            let list = json.arrayValue.map({Workout.fromJson($0)})
            callback(list)
        }
    }
}
