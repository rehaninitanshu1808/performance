module Pagination
  def page
    (params[:page] || 1).to_i
  end

  def per_page
    (params[:per_page] || 20).to_i
  end

  def offset
    (page - 1) * per_page
  end

  def total_pages(total_count)
    (total_count / per_page.to_f).ceil
  end

  def page_details
    {
      page: page,
      per_page: per_page,
      total_count: @total_count,
      total_pages: (@total_count / per_page.to_f).ceil
    }
  end
end
