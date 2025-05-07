import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.style.minHeight = '120px'
  }
  
  reset() {
    this.element.reset()
    this.element.style.minHeight = '120px'
  }
}