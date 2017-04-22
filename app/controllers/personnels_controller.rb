class PersonnelsController < ApplicationController

  before_action :set_personnel, only: [:show, :edit, :update, :destroy, :save]
  before_action :logged_in_personnel

  # GET /personnels
  # GET /personnels.json
  def index
    @personnels = Personnel.all
    @departments = Department.all

		respond_to do |format|
			format.html { render :index }
			format.json { render json: Oj.dump(@personnels.select([:id, :first_name, :last_name, :email, :gender])) }
		end
  end

  # GET /personnels/1
  # GET /personnels/1.json
  def show

    #Get all student in advisors
    @students = @personnel.students;

    #Get department
    @workin = if @personnel.workin.nil? then "" else @personnel.workin.name end
    @manage = if @personnel.manage.nil? then "" else @personnel.manage.name end

		respond_to do |format|
			format.html { render :show }
			format.json { render json: Oj.dump(@personnel) }
		end
  end

  def save

    #Get all student in advisors
    @students = @personnel.students;

    #Get department
    @workin = if @personnel.workin.nil? then "" else @personnel.workin.name end
    @manage = if @personnel.manage.nil? then "" else @personnel.manage.name end

    render  pdf: 'filename.pdf',
            template: 'personnels/show.pdf.erb',
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

  # GET /personnels/new
  def new
    @personnel = Personnel.new
  end

  # GET /personnels/1/edit
  def edit
  end

  # POST /personnels
  # POST /personnels.json
  def create
    @personnel = Personnel.new(personnel_params)

    respond_to do |format|
      if @personnel.save
        format.html { redirect_to @personnel, notice: 'Personnel was successfully created.' }
        format.json { render :show, status: :created, location: @personnel }
      else
        format.html { render :new }
        format.json { render json: @personnel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /personnels/1
  # PATCH/PUT /personnels/1.json
  def update
    respond_to do |format|
      if @personnel.update(personnel_params)
        format.html { redirect_to @personnel, notice: 'Personnel was successfully updated.' }
        format.json { render :show, status: :ok, location: @personnel }
      else
        format.html { render :edit }
        format.json { render json: @personnel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /personnels/1
  # DELETE /personnels/1.json
  def destroy
    @personnel.destroy
    respond_to do |format|
      format.html { redirect_to personnels_url, notice: 'Personnel was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_personnel
      @personnel = Personnel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def personnel_params
      params.fetch(:personnel, {}).permit(:id, :email, :password, :password_confirmation, :role, :first_name, :last_name)
    end


end
