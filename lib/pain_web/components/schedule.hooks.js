import flatpickr from "flatpickr"

let Calendar = {
  mounted() {
    var node = document.getElementById("calendar")
    var schedule = node.parentElement.parentElement.parentElement

    flatpickr(node, {
      defaultDate: schedule.dataset.day,
      minDate: schedule.dataset.day,
      // dateFormat: "Y-m-d",
      ariaDateFormat: "Y-m-d",
      inline: true,
      onChange: (chosen, day, pickr) => {
        this.pushEventTo(schedule, "schedule_day", { day })
        color(schedule);
      },
      onMonthChange: (chosen) => {
        var month = chosen[0].toISOString().slice(0,7)
        this.pushEventTo(schedule, "schedule_month", { month })
        color(schedule)
      },
    });

    color(schedule);
  }
}

function color(schedule) {
  var possible = JSON.parse(schedule.dataset.possible)
  var max = Math.max(...Object.values(possible))
  var days = [...document.getElementsByClassName("flatpickr-day")]
    .filter(d => !d.classList.contains("flatpickr-disabled"))
    .forEach(d => {
      var number = possible[d.getAttribute("aria-label")]
      var color = d.classList.contains("selected")
      ? "#569ff7"
      : `hsl(150, 60%, ${80 - Math.floor(number / max * 40)}%);`
      d.setAttribute("style", `background-color: ${color}`);
    })
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
