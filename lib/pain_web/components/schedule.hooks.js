import flatpickr from "flatpickr"

let Calendar = {
  mounted() {
    var node = document.getElementById("calendar")
    console.log("Rendering Calendar!");
    console.log(node);
    console.log();
    flatpickr(node, {
      defaultDate: node.dataset.day,
      minDate: node.dataset.day,
      // dateFormat: "Y-m-d",
    });
  }
}

let Clock = {
  mounted() {
    var node = document.getElementById("calendar")
    console.log("Rendering Calendar!");
    console.log(node);
    flatpickr(node, {
      // dateFormat: "Y-m-d",
    });
  }
}

export { Calendar, Clock }
