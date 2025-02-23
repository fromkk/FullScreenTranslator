import Foundation

struct AlertMessage: Sendable, Identifiable {
  var message: String
  var id: String { message }
}
