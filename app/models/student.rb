class Student < ApplicationRecord
	has_many :advisors
	has_many :personnels, :through => :advisors

	has_many :gpas
	belongs_to :curriculum

	#Unfinished
	def update_grade
		@grade_table = Array.new

	    @section_enrolled = Enrollment.where(student_id: self.id).where.not(grade: nil)
	    @section_enrolled.each do |enrollment|
	        section_detail = Section.find_by(id: enrollment.section_id)
	        course_detail = Course.find_by(id: section_detail.course_id)
	        @grade_table.push([enrollment, section_detail, course_detail]) # Enrollment, Section, Course
	    end

	    @grade = Gpa.where(student_id: self.id)
	    @grade.each do |grade|
	    	sum = 0
	    	credit = 0
	    	@grade_table.each do |table|
	    		if table[1].year == grade.year && 
	    			table[1].semester == grade.semester &&
	    				sum += table[2].credit * table[0].grade
	    				credit += table[2].credit
	    		end
	    	end
	    	if credit != 0
	    		grade.gpa = sum/credit
	    		grade.credit = credit
	    	else
	    		grade.gpa = 0
	    		grade.credit = 0
	    	end
	    	grade.save
	    end
	end

	#Unfinished
	def updateGraduation

		#Curriculum
	    @required_subject = Require.where(curriculum_id: self.curriculum_id).order(:course_id)
	    @required_subject_arr = Array.new

	    @required_subject.each do |subject|
	      subject_detail = Course.find_by(id: subject.course_id)
	      @required_subject_arr.push([subject, subject_detail])
	    end

	    @enrolled_course = Enrollment.joins("INNER JOIN sections ON enrollments.section_id = sections.id").select("sections.course_id, enrollments.grade, enrollments.student_id").order("sections.course_id")
	    @required_subject_arr.each do |subject|
    		if @enrolled_course.where("student_id = \'#{self.id}\' and course_id = #{subject[1].id} and not grade = 0").first.nil?
    			return
    		end
    	end
    	if self.status == "Studying"
    		self.status = "Graduated"
    	end
    	self.save
    	return
	end

	def updateData
		update_grade
		updateGraduation
	end

	def gpax

		@gpax = Gpa.find_by_sql("SELECT SUM(credit*gpa)/SUM(credit) as gpax FROM gpas WHERE student_id = '" + self.id + "'")
		@gpax.first.gpax.round(2)
	end
end
