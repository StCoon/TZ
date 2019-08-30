require 'open-uri'
require 'nokogiri'
require 'csv'

def category_parse(main_page_url)
  html = open(main_page_url)
  main_page_doc = Nokogiri::HTML(html)
  puts "Вычисление количества продуктов и страниц категории..."
  #Вычисление количества страниц в категории продукта
  product_count = main_page_doc.xpath("//*[@class='heading-counter']").text.to_i
  page_count = product_count % 25 == 0 ? product_count / 25 : product_count / 25 + 1
  puts "Количество страниц в категории: #{page_count}"
  puts "Количество товаров категории: #{product_count}"
  return page_count
end

def save_to_csv(path, data)
  puts "Открытие файла для записи..."
  CSV.open(path, "wb") do |csv_line|
      csv_line << %w(Name Price Image)
  (0..data.length - 1).each do |line|
    csv_line << line
  end
end
end

def product_parse(all_url)
  rs = []
  all_url.each do |prod|
  page_url = prod
  html = open(page_url)
  page_doc = Nokogiri::HTML(html)
  #Вычисление названия продукта, ссылки на картинку, различных весовок/размерностей, и цен для каждой весовки/размерности
  prod_name = page_doc.xpath("//h1")
  prod_img = page_doc.xpath("//span[@id='view_full_size']//@src")
  prod_size = page_doc.xpath("//span[@class='radio_label']")
  prod_value = page_doc.xpath("//span[@class='price_comb']")#map do |produ_value|
      #/\d+[.,]\d+/.match(produ_value.text)
  #end
  for prod in 0..size.length() - 1
    #занесение собранной информации о товаре в специальную переменную и запись этих данных в файл
    rs.append ["#{prod_name.text} - #{prod_size[prod].text}", prod_value[prod].text, prod_img.text]
  end
end
save_to_csv("rs.csv",rs)
  #Цикл по каждой весовке/размерности
end

def pages_parse(page_count)
  all_pages = []
  (1 .. page_count).each do |i|
    puts "Обработка страницы № #{i}"
  #Открытие отдельных страниц с продуктами категории
  if i == 1
    pages_url = "https://www.petsonic.com/snacks-huesos-para-perros"
    html = open(pages_url)
    pages_doc = Nokogiri::HTML(html)
  else
    pages_url = "https://www.petsonic.com/snacks-huesos-para-perros/?p=#{i}"
    html = open(pages_url)
    pages_doc = Nokogiri::HTML(html)
  end
  #Занесение ссылки на каждый продукт текущей страницы категории в массив
  all_pages.append [pages_doc.xpath("//a[@class ='product_img_link product-list-category-img']//@href")]
  #Цикл по каждой странице с продуктом из текущего набора
  if i == page_count
    puts "Обработка всех страниц завершена."
  else puts "Переход к следующей странице..."
  end
end
product_parse(all_pages)
end
#открытие ссылки с категорией продукта
#ARG_URL = ARGV[0]
#CSV_PATH = ARGV[1]
#Открытие файла, для записи информации
pc = category_parse("https://www.petsonic.com/snacks-huesos-para-perros")
pages_parse(pc)

puts "Все продукты страницы обработаны, данные внесены в файл."
puts "Файл успешно сохранён, результат работы программы: rs.csv "
