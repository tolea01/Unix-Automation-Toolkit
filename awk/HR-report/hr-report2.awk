#!/usr/bin/awk -f

BEGIN {
    FS = ","
    title = "HR REPORT 2"
		file_name = "users.sh"
}

NR > 1 {
    employees = toupper($2)
    salary = $4
    department = $3
		username = $2
    
    employee_salary[employees] = salary
    total_salary += salary
    department_salary[department] += salary
		username_per_department[username] = department
    
    if (salary ~ /^[0-9]+$/ && salary > 8000) {
        employee_tax[employees] = salary * 0.4
    } else if (salary ~ /^[0-9]+$/ && salary > 5000) {
        employee_tax[employees] = salary * 0.3
    } else if (salary ~ /^[0-9]+$/ && salary < 5000) {
        employee_tax[employees] = salary * 0.2
    }
    
    if (salary == 0 || salary == "") {
        salary = "[ESTIMATED]"
    }
}

END {
    print "List of employees:"
    for (emp in employee_salary) {
        print " - " emp
    }
    
    print "\nCalculated employee taxes:"
    for (emp in employee_tax) {
        printf "%s -> %s -> %.2f\n", emp, employee_salary[emp], employee_tax[emp]
    }
    
    print "\nPercentage of the budget consumed by each department:"
    for (dept in department_salary) {
        department_percentage = (department_salary[dept] / total_salary) * 100
        printf "%s : %.2f%%\n", dept, department_percentage
    }

		print "\nCreate groups script: "

		for (username in username_per_department) {
			group = username_per_department[username]
			
			if (system("getent group " group) != 0) {
				printf "The group %s must be created\n", group
				print "sudo groupadd " group >> file_name
			}
		}

		print "\nCreate users script: "

		for (username in username_per_department) {
			group = username_per_department[username]

			if (system("getent passwd " username) != 0) {
				printf "The user %s must be created\n", username
				print "sudo useradd -m -G " group " " username >> file_name
			}
		}
}