class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_personnel

  # GET /courses
  # GET /courses.json
  def index
    @courses = Course.all
    @departments = Department.all
		respond_to do |format|
			format.html { render :index }
			format.json { render json: Oj.dump(@courses) }
		end
  end


  # GET /courses/1
  # GET /courses/1.json
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

    #List all year/sem
    @listYearSem = Section.select(:year, :semester)
                          .group(:year, :semester)
                          .order(year: :desc, semester: :desc)

    #Currrent year/sem
    if !params[:year].nil? and !params[:semester].nil?
      @currentYearSem = {year: params[:year], semester: params[:semester]}
    else
      @section_maxYearSem = @listYearSem.first
      @currentYearSem = {year: @section_maxYearSem.year, semester: @section_maxYearSem.semester}
    end
    @currentYearSem[:year] = @currentYearSem[:year].to_i
    @currentYearSem[:semester] = @currentYearSem[:semester].to_i

    @section = Section.where(course_id: @course.id, 
                        year: @currentYearSem[:year],
                        semester: @currentYearSem[:semester])
                      .order(sec: :asc, 
                        year: :desc,
                        semester: :desc)

    @time = Schedule.find_by_sql("SELECT * 
                                FROM schedules INNER JOIN time_slots 
                                ON time_slots.id = schedules.id")

    @code = Code.find_by_sql("SELECT departments.name as dep_name, codes.*
                          FROM codes INNER JOIN departments
                          ON codes.id = #{@course.code_id}")

    @section_data_arr = Array.new
    @section.each do |sec|
      @time.each do |time|
        @section_data_arr.push([sec, time])
      end
    end

    @StudentYearSem = Enrollment.find_by_sql("
                            SELECT COUNT(*) as num, sections.year, sections.semester
                            FROM enrollments INNER JOIN sections ON sections.id = enrollments.section_id
                            GROUP BY sections.year, sections.semester
                            ORDER BY sections.year, sections.semester")

    @gradeAverage = Enrollment.find_by_sql("
                            SELECT SUM(enrollments.grade)/COUNT(*) as num, sections.year, sections.semester
                            FROM enrollments INNER JOIN sections ON sections.id = enrollments.section_id
                            WHERE enrollments.grade IS NOT NULL
                            GROUP BY sections.year, sections.semester
                            ORDER BY sections.year, sections.semester")

    @gradeList = Enrollment.find_by_sql("
                            SELECT COUNT(*) as num, enrollments.grade
                            FROM enrollments INNER JOIN sections ON sections.id = enrollments.section_id
                            WHERE enrollments.grade IS NOT NULL and sections.year = #{@currentYearSem[:year]} and sections.semester = #{@currentYearSem[:semester]}
                            GROUP BY enrollments.grade
                            ORDER BY enrollments.grade DESC")

    @gradeAlphabet = {4.0 => 'A', 3.5 => 'B+', 3.0 => 'B', 2.5 => 'C+', 2.0 => 'C', 1.5 => 'D+', 1.0 => 'D', 0.0 => 'F', -1.0 => 'W', -2.0 => 'I'}
    @gradeColor = {4.0 => '4caf50', 3.5 => '8bc34a', 3.0 => 'cddc39', 2.5 => 'ffeb3b', 2.0 => 'ffc107', 1.5 => 'ff9800', 1.0 => 'ff5722', 0.0 => 'f44336', -1.0 => 'W', -2.0 => 'I'}

    @current_student_count = @StudentYearSem.select{ |std| 
      (std.year == @currentYearSem[:year] and std.semester == @currentYearSem[:semester])
    }
    if(@current_student_count.length > 0)
      @current_student_count = @current_student_count[0].num
    else
      @current_student_count = 0
    end

    @current_grade = @gradeAverage.select{ |std| 
      (std.year == @currentYearSem[:year] and std.semester == @currentYearSem[:semester])
    }
    if(@current_grade.length > 0)
      @current_grade = sprintf("%.2f", @current_grade[0].num)
    else
      @current_grade = 0
    end

    @current_section_count = @section_data_arr.length


    render 'show'
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit
  end

  # POST /courses
  # POST /courses.json
  def create
    @course = Course.new(course_params)

    respond_to do |format|
      if @course.save
        format.html { redirect_to @course, notice: 'Course was successfully created.' }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /courses/1
  # PATCH/PUT /courses/1.json
  def update
    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to @course, notice: 'Course was successfully updated.' }
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.json
  def destroy
    @course.destroy
    respond_to do |format|
      format.html { redirect_to courses_url, notice: 'Course was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def course_params
      params.fetch(:course, {}).permit(:name, :course_category_id, :credit)
    end
end
