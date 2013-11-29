class PostsController < ApplicationController

  #http_basic_authenticate_with :name => "centrex", :password => "centrex", :except => [:index]

  # GET /posts
  # GET /posts.json
  def index
  
    session[ :viewdate ] = Date.today
  
    @posts = Post.where("created_at >= ?", Date.today).order(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
      format.csv { send_data @posts.to_csv }
      format.xls
    end
    
  end

  def show
    redirect_to action: "index"
  end

  # GET /posts/yyyy/mm/dd/name/:name
  def posts_date

    if params[ :date ]
      session[ :viewdate ] = Date.parse params[ :date ]
    else
      session[ :viewdate ] = ( [ params[:year], params[:month], params[:day] ].all? ? Date.new( params[:year].to_i, params[:month].to_i, params[:day].to_i ) : Date.today )
    end
  
    session[ :name ] = if params[:name].nil?
      session[ :name ]
    elsif params[:name] == 'All'
      'All'
    elsif Post::NAMES.include?( params[:name] )
      Post::ENGINEERNAMES[ Post::NAMES.index( params[:name] ) ]
    elsif Post::ENGINEERNAMES.include?( params[:name] )
      params[ :name ]
    else
      'All'
    end

    @posts = Post.filter( session[ :viewdate ], session[ :name ] )
    
    respond_to do |format|
      format.html { render :index }
      format.json { render json: @posts }
      format.csv { send_data @posts.to_csv }
      format.xls { render :index }
    end

  end
  
  # GET /posts/new
  # GET /posts/new.json
  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.json
  def create
  
    @post = Post.new(params[:post])

    respond_to do |format|
      if @post.save
        session[ :name ] = @post.name
        session[ :viewdate ] = Date.today
        session[ :endtime ] = @post.endtime
        @posts = Post.filter( session[ :viewdate ], session[ :name ] )
        format.html { render :index }
        
        #format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render json: @post, status: :created, location: @post }
      else
        format.html { render action: "new" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
    
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        
        session[ :name ] = @post.name
        session[ :viewdate ] = @post.created_at.to_date
        session[ :endtime ] = @post.endtime
        @posts = Post.filter( session[ :viewdate ], session[ :name ] )
        format.html { render :index }
        
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end
  
  def totals
     totals = Post.worktype_hours_by_month( Date.new( params[:year].to_i, params[:month].to_i, 1 ) ) 
     render :totals, :locals => { :totals => totals }
  end
  
end
