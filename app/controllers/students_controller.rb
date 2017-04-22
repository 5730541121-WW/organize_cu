class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy, :save]
  before_action :logged_in_personnel

  # GET /students
  # GET /students.json
  def index
    @students = Student.all
    respond_to do |format|
			format.html { render :index }
			format.json { render json: Oj.dump(@students) }
		end
  end



  # GET /students/1
  # GET /students/1.json
  def show
    @colorList = [
        '#f44336',
        '#ff5722',
        '#ff9800',
        '#ffc107',
        '#ffeb3b',
        '#cddc39',
        '#8bc34a',
        '#4caf50',
        '#009688',
        '#00bcd4',
        '#03a9f4',
        '#2196f3']

    @advisor_name_arr = Array.new
    @advisor = Advisor.where(student_id: @student.id)
    @advisor.each do |adv|
      x = Personnel.find_by(id: adv.personnel_id)
      @advisor_name_arr.push(x)
    end

    #Academic Info
    @gpa = Gpa.where(student_id:@student.id).order(year: :desc, semester: :desc)
    @gpax = Gpa.find_by_sql("SELECT SUM(credit*gpa)/SUM(credit) as gpax FROM gpas WHERE student_id = \'"+params[:id]+"\'")

    #Group Info
    @in_group = BelongTo.where(student_id: @student.id)

    #Leave Info
    @personal_leave_arr = Array.new
    @sick_leave_arr = Array.new

    @in_group.each do |group|
      @leave = Leave.where(group_id: group.id).order(start_date: :desc)
      @leave.each do |leave|
        personal_leave = PersonalLeave.where(leave_id:leave.id).first
        sick_leave = SickLeave.where(leave_id:leave.id).first
        if !personal_leave.nil?
          @personal_leave_arr.push([leave, personal_leave])
        else
          @sick_leave_arr.push([leave, sick_leave])
        end
      end
    end

    #Portfolio
    @competition_portfolio_arr = Array.new
    @activity_portfolio_arr = Array.new

    @in_group.each do |group|
      @portfolio = Portfolio.where(group_id: group.id).order(date: :desc)
      @portfolio.each do |port|
        competition_portfolio = Competition.where(portfolio_id:port.id).first
        activity_portfolio = Activity.where(portfolio_id:port.id).first
        if !competition_portfolio.nil?
          @competition_portfolio_arr.push([port, competition_portfolio])
        else
          @activity_portfolio_arr.push([port, activity_portfolio])
        end
      end
    end

    #LogBreak
    @breaking_arr = Array.new
    @breaking = LogBreak.where(student_id: @student.id)
    @breaking.each do |_break|
      rule = Rule.find_by(id: _break.rule_id)
      @breaking_arr.push([_break, rule])
    end

    #Curriculum
    @required_subject = Require.where(curriculum_id: @student.curriculum_id).order(:course_id)
    @required_subject_arr = Array.new
    @required_subject.each do |subject|
      subject_detail = Course.find_by(id: subject.course_id)
      @required_subject_arr.push([subject, subject_detail])
    end

    @enrolled_course = Enrollment.joins("INNER JOIN sections ON enrollments.section_id = sections.id").select("sections.course_id, enrollments.grade, enrollments.student_id").order("sections.course_id")

    respond_to do |format|
      format.html { render :show }
      format.json { render json: Oj.dump(@student) }
    end


  end

  def save


    #Academic Info
    @gpa = Gpa.where(student_id:@student.id)
    @gpax = Gpa.find_by_sql("SELECT SUM(credit*gpa)/SUM(credit) as gpax FROM gpas WHERE student_id = \'"+"5731002421"+"\'")

    #Group Info
    @in_group = BelongTo.where(student_id: @student.id)

    #Leave Info
    @personal_leave_arr = Array.new
    @sick_leave_arr = Array.new

    @in_group.each do |group|
      @leave = Leave.where(group_id: group.id).order(start_date: :desc)

      @leave.each do |leave|
        personal_leave = PersonalLeave.where(leave_id:leave.id).first
        sick_leave = SickLeave.where(leave_id:leave.id).first

        if !personal_leave.nil?
          @personal_leave_arr.push([leave, personal_leave])
        else
          @sick_leave_arr.push([leave, sick_leave])
        end
      end
    end

    render  pdf: 'filename.pdf',
            template: 'students/show.pdf.erb',
            page_size: 'A4',
            margin: {
              :top => 40
            },
            header:  {
              spacing: 10,
              html: {
                template: 'layouts/header.pdf.erb',
              },
            }
  end

  # GET /students/new
  def new
    @student = Student.new
  end

  # GET /students/1/edit
  def edit
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(student_params)

    respond_to do |format|
      if @student.save
        format.html { redirect_to @student, notice: 'Student was successfully created.' }
        format.json { render :show, status: :created, location: @student }
      else
        format.html { render :new }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /students/1
  # PATCH/PUT /students/1.json
  def update
    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to @student, notice: 'Student was successfully updated.' }
        format.json { render :show, status: :ok, location: @student }
      else
        format.html { render :edit }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1
  # DELETE /students/1.json
  def destroy
    @student.destroy
    respond_to do |format|
      format.html { redirect_to students_url, notice: 'Student was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.fetch(:student, {})
    end
end
