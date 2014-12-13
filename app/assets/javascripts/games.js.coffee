# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

//= require chessboard
//= require chess

$( document ).ready () ->
  window.board = null
  window.game = null
  window.loading = false

  loading_start = () ->
    window.loading = true
    loading_box = $('#loading_box')
    if loading_box.length is 0
      loading_box = document.createElement("div")
      loading_box.setAttribute("id", "loading_box")
      loading_box.setAttribute("class", "alert alert-danger")
      document.body.appendChild(loading_box)
      loading_box = $('#loading_box')
      loading_box.html('Loading')
    loading_box.show()

  loading_finish = () ->
    window.loading = false
    loading_box = $('#loading_box')
    loading_box.hide()

  removeGreySquares = () ->
    $('#board .square-55d63').css('background', '')

  greySquare = (square) ->
    squareEl = $('#board .square-' + square)
    background = '#a9a9a9'
    background = '#696969' if squareEl.hasClass('black-3c85d') is true
    squareEl.css('background', background)

  onDragStart = (source, piece) ->
    if window.game.game_over() or window.loading or (window.game.turn() is 'w' and piece.search(/^b/) isnt -1) or (window.game.turn() is 'b' and piece.search(/^w/) isnt -1)
      return false

  onDrop = (source, target) ->
    removeGreySquares()

    move = window.game.move(
      from: source,
      to: target,
      promotion: 'q'
    )
    if not move
      document.flash_message('Invalid Move!')
      return 'snapback'

  onMouseoverSquare = (square, piece) ->
    moves = window.game.moves(
      square: square,
      verbose: true
    )
    return if moves.length is 0
    greySquare(square)
    for move in moves
      greySquare(move.to)

  onMouseoutSquare = (square, piece) ->
    removeGreySquares()

  onSnapEnd = (source, target, piece) ->
    # console.log("----------SnapEnd----------")
    # console.log("Source: " + source)
    # console.log("Target: " + target)
    # console.log("Piece: " + piece)
    loading_start()
    history = window.game.history()
    $.getJSON( "/games/"+game_id+"/move/"+history[history.length-1]+".json", (data) ->
      document.flash_message(data.error+" Try reload") if data.error
      window.board.position(window.game.fen())
      loading_finish()
    )

  cfg =
    position: ''
    draggable: true
    onDragStart: onDragStart
    onDrop: onDrop
    onMouseoutSquare: onMouseoutSquare
    onMouseoverSquare: onMouseoverSquare
    onSnapEnd: onSnapEnd

  if game_id?
    $.getJSON( "/games/"+game_id+".json", (data) ->
      document.flash_message(data.error) if data.error
      cfg.position = data.fen
      console.log(data.fen)
      window.game = new Chess(data.fen)
      window.board = new ChessBoard('board', cfg)
    )
