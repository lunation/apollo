local VECTOR = {}

local new

function VECTOR:__ctor(x,y)
	self.x= x or 0
	self.y= y or 0
end

function VECTOR:copy()
	return new(self.x,self.y)
end

function VECTOR:__unm()
	return new(-self.x,-self.y)
end

function VECTOR:neg()
	self.x=-self.x
	self.y=-self.y
	return self
end

function VECTOR:__tostring()
	return "< "..self.x.." , "..self.y.." >"
end

new = Class(VECTOR)

Vector = new