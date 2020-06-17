# frozen_string_literal: true

# Routes for the cool books of this application
class ShopApplication
  path :shop, '/shop'
  path :books_new, '/shop/books/new'
  path :books, '/shop/books'
  path :stationerys, '/shop/stationerys'
  path :stationerys_new, '/shop/stationerys/new'
  path :books_filter, '/shop/books/filter'
  path :statistics, '/shop/books/statistics'
  path :lists, '/shop/lists'
  path :lists_new, '/shop/lists/new'

  path Book do |book, action|
    if action
      "/shop/books/#{book.id}/#{action}"
    else
      "/shop/books/#{book.id}"
    end
  end

  path Stationery do |stationery, action|
    if action
      "/shop/stationerys/#{stationery.id}/#{action}"
    else
      "/shop/stationerys/#{stationery.id}"
    end
  end

  path List do |list, action, product_name|
    if product_name
      "/shop/lists/#{list.id}/#{list.id_by_name(product_name)}/#{action}"
    elsif action
      "/shop/lists/#{list.id}/#{action}"
    else
      "/shop/lists/#{list.id}"
    end
  end

  hash_branch('shop') do |r|
    set_layout_options(template: '../views/layout')

    r.is do
      append_view_subdir('shop')
      view('shop')
    end

    r.on 'lists' do
      append_view_subdir('lists')

      r.is do
        @lists = opts[:lists].all_lists
        view('lists')
      end

      r.on 'new' do
        r.get do
          @parameters = {}
          view('list_new')
        end

        r.post do
          @parameters = DryResultFormeWrapper.new(ListAddFormSchema.call(r.params))
          if opts[:lists].names.include?(@parameters[:name])
            @flag = true
          end
          if @parameters.success? && !@flag
            lists = opts[:lists].add_list(@parameters[:name])

            r.redirect lists_path
          else
            view('list_new')
          end
        end
      end

      r.on Integer do |list_id|
        @list = opts[:lists].list_by_id(list_id)
        next if @list.nil?

        r.is do
          view('list')
        end

        r.on 'delete' do
          r.get do
            @parameters = {}
            view('list_delete')
          end

          r.post do
            @parameters = DryResultFormeWrapper.new(DeleteSchema.call(r.params))
            if @parameters.success?
              opts[:lists].delete_list(@list.id)
              r.redirect(lists_path)
            else
              view('list_delete')
            end
          end
        end

        r.on Integer do |product_id|
          @product = opts[:lists].list_by_id(list_id).product_by_id(product_id)
          next if @product.nil?

          r.on 'delete' do
            r.get do
              @parameters = {}
              view('product_delete')
            end
            r.post do
              @parameters = DryResultFormeWrapper.new(DeleteSchema.call(r.params))
              if @parameters.success?
                opts[:lists].list_by_id(list_id).delete_product(product_id)
                r.redirect(path(@list))
              else
                view('product_delete')
              end
            end
          end
        end
      end
    end

    r.on 'stationerys' do
      append_view_subdir('stationerys')

      r.is do
        @stationerys = opts[:stationerys].all_stationerys
        view('stationerys')
      end

      r.on 'new' do
        r.get do
          @parameters = {}
          view('stationerys_new')
        end

        r.post do
          @parameters = DryResultFormeWrapper.new(StationeryFormSchema.call(r.params))
          if @parameters.success?
            stationery = opts[:stationerys].add_stationery(@parameters)
            r.redirect(stationerys_path)
          else
            view('stationerys_new')
          end
        end
      end

      r.on Integer do |stationery_id|
        @stationery = opts[:stationerys].stationery_by_id(stationery_id)
        pp @stationary
        next if @stationery.nil?

        r.is do
          view('stationery')
        end

        r.on 'add' do
          r.get do
            @list = opts[:lists].all_lists
            pp @list
            @names = opts[:lists].names
            @parameters = {}
            view('stationery_add')
          end

          r.post do
            @parameters = DryResultFormeWrapper.new(ProductAddFormSchema.call(r.params))
            if @parameters.success?
              @lists = opts[:lists]
              list = @lists.list_by_id(@lists.id_by_name(@parameters[:name]))
              list.add_product(@stationery)
              r.redirect(path(list))
            else
              view('stationery_add')
            end
          end
        end

        r.on 'delete' do
          r.get do
            @parameters = {}
            view('stationery_delete')
          end

          r.post do
            @parameters = DryResultFormeWrapper.new(DeleteSchema.call(r.params))
            if @parameters.success?
              opts[:stationerys].delete_stationery(@stationery.id)
              r.redirect(stationerys_path)
            else
              view('stationery_delete')
            end
          end
        end
      end
    end

    r.on 'books' do
      append_view_subdir('books')

      r.is do
        @params = DryResultFormeWrapper.new(BookFilterFormSchema.call(r.params))
        @filtered_books = if @params.success?
                            opts[:books].filter(@params[:name], @params[:genre])
                          else
                            opts[:books].all_books
                          end
        view('books')
      end

      r.on 'statistics' do
        r.get do
          puts 'я здесь'
          @books = opts[:books]
          @stationerys = opts[:stationerys]
          view('statistics')
        end
      end

      r.on Integer do |book_id|
        @book = opts[:books].book_by_id(book_id)
        next if @book.nil?

        r.is do
          view('book')
        end

        r.on 'add' do
          r.get do
            @list = opts[:lists].all_lists
            @names = opts[:lists].names
            @parameters = {}
            view('book_add')
          end

          r.post do
            @parameters = DryResultFormeWrapper.new(ProductAddFormSchema.call(r.params))
            if @parameters.success?
              @lists = opts[:lists]
              list = @lists.list_by_id(@lists.id_by_name(@parameters[:name]))
              list.add_product(@book)
              r.redirect(path(list))
            else
              view('book_add')
            end
          end
        end

        r.on 'delete' do
          r.get do
            @parameters = {}
            view('book_delete')
          end

          r.post do
            @parameters = DryResultFormeWrapper.new(DeleteSchema.call(r.params))
            if @parameters.success?
              opts[:books].delete_book(@book.id)
              r.redirect(books_path)
            else
              view('book_delete')
            end
          end
        end
      end

      r.on 'new' do
        r.get do
          @parameters = {}
          view('book_new')
        end

        r.post do
          @parameters = DryResultFormeWrapper.new(BookFormSchema.call(r.params))
          if @parameters.success?
            book = opts[:books].add_book(@parameters)
            r.redirect(path(book))
          else
            view('book_new')
          end
        end
      end
    end
  end
end
