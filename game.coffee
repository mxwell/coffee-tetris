unit = 20
field_x = 10
field_y = 20

# colors
bg_color = '#EEEEEE'

# azure, green, red, orange, purple, yellow, blue
brick_body_color =   ['#33CCFF', '#00FF00', '#FF0000', '#FF9933', '#FF66FF', '#FFFF00', '#0000CC']
brick_border_color = ['#0099CC', '#33CC33', '#CC0000', '#CC6600', '#CC33FF', '#FFFF66', '#000066']

arrow = {left: 37, up: 38, right: 39, down: 40}

class Tetris
	constructor: () ->
		@canv = $('#canv')[0]
		@ctx = @canv.getContext('2d')

	init: () ->
		@canv.width = field_x * unit
		@canv.height = field_y * unit

		@ctx.fillStyle = bg_color
		@ctx.fillRect(0, 0, @canv.width, @canv.height)

		document.onkeydown = this.keyDownHandler

	drawBrick: (x, y, color) ->
		lf = x * unit
		tp = y * unit
		@ctx.fillStyle = brick_border_color[color]
		@ctx.fillRect(lf, tp, unit, unit)

		@ctx.fillStyle = brick_body_color[color]
		@ctx.fillRect(lf + 3, tp + 3, unit - 6, unit - 6)

	eraseBrick: (x, y) ->
		lf = x * unit
		tp = y * unit
		@ctx.fillStyle = bg_color
		@ctx.fillRect(lf, tp, unit, unit)

	drawFigure: (figure) ->
		x = figure.x
		y = figure.y
		this.drawBrick(x + brick.x, y + brick.y, brick.color_id) for brick in figure.points

	eraseFigure: (figure) ->
		x = figure.x
		y = figure.y
		this.eraseBrick(x + brick.x, y + brick.y) for brick in figure.points

	brickIsValid: (x, y) ->
		if !(0 <= x && x < field_x && 0 <= y && y < field_y)
			return false
		intersected = (brick for brick in @bricks when (brick.x == x && brick.y == y))
		intersected.length == 0

	figureIsValid: (figure, dx, dy) ->
		x = figure.x + dx
		y = figure.y + dy
		bad = (brick for brick in figure.points when !this.brickIsValid(brick.x + x, brick.y + y))
		return bad.length == 0

	moveFigure: (dx, dy) ->
		if !this.figureIsValid(@figure, dx, dy)
			return null
		this.eraseFigure @figure
		@figure.x += dx
		@figure.y += dy
		this.drawFigure @figure
		@figure

	keyDownHandler: (evt) ->
		switch evt.keyCode
			when arrow.left
				window.game.moveFigure(-1, 0)
			when arrow.right
				window.game.moveFigure(1, 0)
			when arrow.down
				window.game.moveFigure(0, 1)
		null

	makeFigureT: (xoffset, yoffset, color, orientation = 0) ->
		if orientation == 0
			points = [ [0, 0], [1, 0], [2, 0], [1, 1] ]
		else if orientation == 1
			points = [ [0, 0], [0, 1], [0, 2], [1, 1] ]
		else if orientation == 2
			points = [ [0, 1], [1, 0], [1, 1], [2, 1] ]
		else
			points = [ [0, 1], [1, 0], [1, 1], [1, 2] ]
		pts = for point in points
			{x: point[0], y: point[1], color_id: color}
		{x: xoffset, y: yoffset, points: pts}

	nextFigure: () ->
		fx = @figure.x
		fy = @figure.y
		figure_bricks = for brick in @figure.points
							{x: brick.x + fx, y: brick.y + fy, color_id: brick.color_id}
		@bricks = @bricks.concat(figure_bricks)
		@figure = this.makeFigureT(5, 0, 1)
		if this.figureIsValid(@figure, 0, 0)
			this.drawFigure(@figure)
		else
			window.clearInterval(window.timerVar)
			alert "Game is over"


	timerHandler: () ->
		if window.game.moveFigure(0, 1) != null
			# good
		else
			window.game.nextFigure()

	run: () ->
		@bricks = []
		@figure = this.makeFigureT(5, 5, 1)
		this.drawFigure(@figure)
		window.timerVar = window.setInterval(this.timerHandler, 500)

$(document).ready(() ->
	game = new Tetris
	window.game = game
	game.init()
	game.run()
)