unit = 20
field_x = 10
field_y = 20
border_width = 3
border_2width = border_width * 2

# colors
bg_color = '#EEEEEE'

# azure, green, red, orange, purple, yellow, blue
brick_body_color =   ['#33CCFF', '#00FF00', '#FF0000', '#FF9933', '#FF66FF', '#FFFF00', '#0000CC']
brick_border_color = ['#0099CC', '#33CC33', '#CC0000', '#CC6600', '#CC33FF', '#FFFF66', '#000066']

highlight_body_color = '#FFFFFF'
highlight_border_color = "#000000"

arrow = {left: 37, up: 38, right: 39, down: 40}

figures = [
	[ [0, 0], [1, 0],  [1, -1], [2, 0]  ],
	[ [0, 0], [0, -1], [1, 0],  [2, 0]  ],
	[ [0, 0], [1, 0],  [2, 0],  [2, -1] ],
	[ [0, 0], [1, 0],  [1, -1], [2, -1] ],
	[ [0, -1], [1, 0], [1, -1], [2, 0] ],
	[ [0, 0], [1, 0],  [2, 0],  [3, 0]  ],
	[ [0, 0], [1, 0],  [0, -1], [1, -1] ],
]

class Tetris
	constructor: () ->
		@canv = $('#canv')[0]
		@ctx = @canv.getContext('2d')

	clearField: () ->
		@ctx.fillStyle = bg_color
		@ctx.fillRect(0, 0, @canv.width, @canv.height)

	init: () ->
		@canv.width = field_x * unit
		@canv.height = field_y * unit

		this.clearField()		

		document.onkeydown = this.keyDownHandler

	drawBrick: (x, y, color) ->
		lf = x * unit
		tp = y * unit
		@ctx.fillStyle = brick_border_color[color]
		@ctx.fillRect(lf, tp, unit, unit)

		@ctx.fillStyle = brick_body_color[color]
		@ctx.fillRect(lf + border_width, tp + border_width, unit - border_2width, unit - border_2width)

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

	rotateFigureBricks: (bricks) ->
		rotated = for brick in bricks
			{ x: brick.y, y: -brick.x, color_id: brick.color_id }
		base = rotated.reduce (acc, brick) ->
			if brick.y > acc.y || (brick.y == acc.y && brick.x < acc.x)
				acc = brick
			acc
		for brick in rotated
			{ x: brick.x - base.x, y: brick.y - base.y, color_id: brick.color_id }

	moveFigure: (dx, dy) ->
		if !this.figureIsValid(@figure, dx, dy)
			return null
		this.eraseFigure @figure
		@figure.x += dx
		@figure.y += dy
		this.drawFigure @figure
		@figure

	rotateFigure: () ->
		rotated = { x: @figure.x, y: @figure.y, points: this.rotateFigureBricks(@figure.points) }
		if !this.figureIsValid(rotated, 0, 0)
			return null
		this.eraseFigure @figure
		@figure = rotated
		this.drawFigure @figure
		@figure

	keyDownHandler: (evt) ->
		switch evt.keyCode
			when arrow.left
				window.game.moveFigure(-1, 0)
			when arrow.up
				window.game.rotateFigure()
			when arrow.right
				window.game.moveFigure(1, 0)
			when arrow.down
				window.game.moveFigure(0, 1)
		null

	getRandom: (upper_bound) ->
		Math.floor(Math.random() * upper_bound)

	rotate: (points, times) ->
		for it in [1..times]
			points = ([point[1], -point[0]] for point in points)
		points

	makeFigure: () ->
		color = this.getRandom brick_body_color.length
		figure = this.getRandom figures.length
		rotations = this.getRandom 3
		points = this.rotate figures[figure], rotations
		height = 0
		pts = for point in points
			if height < -point[1]
				height = -point[1]
			{x: point[0], y: point[1], color_id: color}
		{x: 4, y: height + 1, points: pts}

	highlightRow: (row) ->
		tp = row * unit
		width = unit * field_x
		@ctx.fillStyle = highlight_border_color
		@ctx.fillRect(0, tp, width, unit)

		@ctx.fillStyle = highlight_body_color
		@ctx.fillRect(border_width, tp + border_width, width - border_2width, unit - border_2width)

	checkBricks: () ->
		counts = (0 for i in [0..(field_y - 1)])
		shifts = (0 for i in [0..(field_y - 1)])
		for brick in @bricks
			counts[brick.y] += 1
		rows_decrement = 0
		for i in [(field_y - 1)..0]
			if counts[i] >= field_x
				this.highlightRow(i)
				rows_decrement += 1
			shifts[i] = rows_decrement
		if rows_decrement > 0
			this.clearField()
			@bricks = ({ x: brick.x, y: brick.y + shifts[brick.y], color_id: brick.color_id } for brick in @bricks when counts[brick.y] < field_x)
			for brick in @bricks
				this.drawBrick(brick.x, brick.y, brick.color_id)
		null

	nextFigure: () ->
		fx = @figure.x
		fy = @figure.y
		figure_bricks = for brick in @figure.points
							{x: brick.x + fx, y: brick.y + fy, color_id: brick.color_id}
		@bricks = @bricks.concat(figure_bricks)
		this.checkBricks()
		@figure = this.makeFigure()
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
		@figure = this.makeFigure()
		this.drawFigure(@figure)
		window.timerVar = window.setInterval(this.timerHandler, 500)

$(document).ready(() ->
	game = new Tetris
	window.game = game
	game.init()
	game.run()
)