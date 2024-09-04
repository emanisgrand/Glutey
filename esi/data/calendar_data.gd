# res://esi/data/calendar_data.gd
extends Node

const DAYS_IN_WEEK = 7
const MONTHS_IN_YEAR = 12

var days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
var month_names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
var day_names = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

func is_leap_year(year: int) -> bool:
	return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)

func get_days_in_month(year: int, month: int) -> int:
	if month == 2 and is_leap_year(year):
		return 29
	return days_in_month[month - 1]

func get_month_name(month: int) -> String:
	return month_names[month - 1]

func get_day_name(day: int) -> String:
	return day_names[day]

func get_first_weekday_of_month(year: int, month: int) -> int:
	var d = 1
	var m = month
	var y = year
	if m < 3:
		m += 12
		y -= 1
	return (d + (13 * (m + 1)) / 5 + y + y / 4 - y / 100 + y / 400) % 7

func get_calendar_data(year: int, month: int) -> Dictionary:
	var first_day = get_first_weekday_of_month(year, month)
	var days_count = get_days_in_month(year, month)
	
	return {
		"year": year,
		"month": month,
		"month_name": get_month_name(month),
		"first_day": first_day,
		"days_count": days_count
	}
