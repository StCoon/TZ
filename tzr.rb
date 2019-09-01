require 'curb'
require 'nokogiri'
require 'csv'

class Parse

  def category_parse(main_page_url)
    html = Curl::Easy.perform(main_page_url).body
    main_page_doc = Nokogiri::HTML(html)
    puts "Вычисление количества продуктов и страниц категории..."
    #Вычисление количества страниц в категории продукта
    product_count = main_page_doc.xpath("//*[@class='heading-counter']").text.to_i
    page_count = product_count % 25 == 0 ? product_count / 25 : product_count / 25 + 1
    puts "Количество страниц в категории: #{page_count}"
    puts "Количество товаров категории: #{product_count}"
    page_count
  end

  def save_to_csv(path, data)
    puts "Открытие файла для записи..."
    CSV.open(path, "wb") do |csv_line|
        csv_line << %w(Name Price Image)
        data.each do |line|
          csv_line << line
        end
      end
      puts "Файл успешно сохранён, результат работы программы: #{CSV_PATH}"
    end

    def product_parse(all_url)
      rs = []
      all_url.each do |prod|
        page_url = prod
        puts "Скачивается продукт: >>>  #{page_url}"
        html = Curl::Easy.perform(page_url.text).body
        page_doc = Nokogiri::HTML(html)
        #Вычисление названия продукта, ссылки на картинку, различных весовок/размерностей, и цен для каждой весовки/размерности
        prod_name = page_doc.xpath("//h1")
        prod_img = page_doc.xpath("//span[@id='view_full_size']//@src")
        prod_size = page_doc.xpath("//span[@class='radio_label']")
        prod_value = page_doc.xpath("//span[@class='price_comb']").map do |produ_value|
            /\d+[.,]\d+/.match(produ_value.text)
            end
        for prod in 0...prod_size.length()
          #занесение собранной информации о товаре в специальную переменную и запись этих данных в файл
          rs.append ["#{prod_name.text} - #{prod_size[prod].text}", prod_value[prod], prod_img.text]
        end
      end
      save_to_csv(CSV_PATH,rs)
  #Цикл по каждой весовке/размерности
  end

  def pages_parse(page_count)
    all_pages_url = []
    pages_url = ARG_URL
    html = Curl::Easy.perform(pages_url).body
    pages_doc = Nokogiri::HTML(html)
    all_pages_url += pages_doc.xpath("//a[@class ='product_img_link product-list-category-img']//@href")
      (2 .. page_count).each do |i|
        puts "Обработка страницы № #{i}"
        #Открытие отдельных страниц с продуктами категории
        pages_url = ARG_URL + "?p=#{i}"
        html = Curl::Easy.perform(pages_url).body
        pages_doc = Nokogiri::HTML(html)
        #Занесение ссылки на каждый продукт текущей страницы категории в массив
        all_pages_url += pages_doc.xpath("//a[@class ='product_img_link product-list-category-img']//@href")
        #Цикл по каждой странице с продуктом из текущего набора
          if i == page_count
            puts "Обработка всех страниц завершена."
          else puts "Переход к следующей странице..."
          end
        end
    product_parse(all_pages_url)
  end
end
#открытие ссылки с категорией продукта
ARG_URL = ARGV[0]
CSV_PATH = ARGV[1]
#Открытие файла, для записи информации
p = Parse.new
pc = p.category_parse(ARG_URL)
p.pages_parse(pc)
