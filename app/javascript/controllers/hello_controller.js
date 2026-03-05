import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "test", "test2" ]

  greet() {
    //DOMが存在するかチェック可能
    console.log(this.hasTestTarget);

    this.testTarget.textContent = "Hello World!"
    this.testTarget.style.color = "red"
    this.test2Target.textContent = "test2"
  }
}
