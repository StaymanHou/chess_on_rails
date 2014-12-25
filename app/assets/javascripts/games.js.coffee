# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

//= require chessboard
//= require chess

$( document ).ready () ->
  window.board = null
  window.game = null
  window.loading = false

  check_game_over = () ->
    if window.game.moves().length <= 0
      winner = 'black'
      if window.game.turn() is 'b'
        winner = 'white'
      document.flash_message('winner: '+winner)

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

  get_score = (fen) ->
    zi = fen.split(" ")[0]
    turn = fen.split(" ")[1]
    score = 0
    for z in zi
      switch z
        when 'r' then score += 10
        when 'n' then score += 7
        when 'b' then score += 7
        when 'q' then score += 20
        when 'k' then score += 200
        when 'p' then score += 2
        when 'R' then score -= 10
        when 'N' then score -= 7
        when 'B' then score -= 7
        when 'Q' then score -= 20
        when 'K' then score -= 200
        when 'P' then score -= 2
    return -score if turn is 'b'
    return score

  get_move_score = (fen, move) ->
    local_game = new Chess(fen)
    local_game.move(move)
    score = get_score(local_game.fen())
    return score

  get_best_score = (fen, steps) ->
    turn = fen.split(" ")[1]
    dec = turn is 'b' ? -1 : 1
    return dec * get_score(fen) if steps is 0
    local_game = new Chess(fen)
    possibleMoves = local_game.moves()
    return dec * Infinity if possibleMoves.length is 0
    best_score = -Infinity
    for move in possibleMoves
      next_game = new Chess(fen)
      next_game.move(move)
      score = get_best_score(next_game.fen(), steps-1)
      best_score = score if score > best_score
    return dec * best_score

  get_best_move = (fen, steps) ->
    local_game = new Chess(fen)
    possibleMoves = local_game.moves()
    return if possibleMoves.length is 0
    best_moves = []
    best_score = -Infinity
    for move in possibleMoves
      next_game = new Chess(fen)
      next_game.move(move)
      score = get_best_score(next_game.fen(), steps-1)
      if score > best_score
        best_moves = [move]
        best_score = score
      else if score is best_score
        best_moves.push(move)
    randomIndex = Math.floor(Math.random() * best_moves.length)
    return best_moves[randomIndex]

  makeRandomMove = () ->
    possibleMoves = window.game.moves()
    return if possibleMoves.length is 0
    randomIndex = Math.floor(Math.random() * possibleMoves.length)
    game.move(possibleMoves[randomIndex])
    board.position(game.fen())

  makeGoodMove = () ->
    possibleMoves = window.game.moves()
    return if possibleMoves.length is 0
    best_moves = []
    best_score = -Infinity
    for move in possibleMoves
      score = get_move_score(window.game.fen(), move)
      if score > best_score
        best_moves = [move]
        best_score = score
      else if score is best_score
        best_moves.push(move)
    randomIndex = Math.floor(Math.random() * best_moves.length)
    window.game.move(best_moves[randomIndex])
    window.board.position(window.game.fen())

  makeBetterMove = (steps) ->
    () ->
      move = get_best_move(window.game.fen(), steps)
      window.game.move(move)
      window.board.position(window.game.fen())

  makeMove = makeGoodMove

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
    loading_start()
    history = window.game.history()
    $.getJSON( "/games/"+game_id+"/move/"+history[history.length-1]+".json", (data) ->
      document.flash_message(data.error+" Try reload") if data.error
      window.board.position(window.game.fen())
      check_game_over()
      makeMove()
      history = window.game.history()
      $.getJSON( "/games/"+game_id+"/move/"+history[history.length-1]+".json", (data) ->
        return
      )
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
      window.game = new Chess(data.fen)
      window.board = new ChessBoard('board', cfg)
      check_game_over()
    )
