document.addEventListener("DOMContentLoaded", function(){
  document.getElementById('search').addEventListener("submit", function(e){
    e.preventDefault()
    var resultElem = document.getElementById("result")
    var form = e.target
    var data = new FormData(form)
    var request = new XMLHttpRequest()

    resultElem.innerText = 'Loading...'

    request.onload = function(){
      resultElem.innerText = request.responseText
    }

    request.open(form.method, form.action)
    request.send(data)
  })
})