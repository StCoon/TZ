require 'open-uri'
require 'nokogiri'
require 'csv'

#открытие ссылки с категорией продукта
ARG_URL = ARGV[0]
CSV_PATH = ARGV[1]
main_page_url = ARG_URL
html = Curl::Easy.perform(main_page_url).body
main_page_doc = Nokogiri::HTML(html)
puts "Вычисление количества продуктов и страниц категории..."
#Вычисление количества страниц в категории продукта
product_count = main_page_doc.xpath("//*[@class='heading-counter']").text.to_i
page_count = product_count % 25 == 0 ? product_count / 25 : product_count / 25 + 1
puts "Количество страниц в категории: #{page_count}"
puts "Количество товаров категории: #{product_count}"
#Открытие файла, для записи информации
puts "Открытие файла для записи..."
CSV.open(CSV_PATH, "wb") do |csv_line|
    csv_line << %w(Name Price Image)
(1 .. page_count).each do |i|
  puts "Обработка страницы № #{i}"
#Открытие отдельных страниц с продуктами категории
if i == 1
  pages_url = ARG_URL
  html = Curl::Easy.perform(pages_url).body
  pages_doc = Nokogiri::HTML(html)
else
  pages_url = ARG_URL+"?p=#{i}"
  html = Curl::Easy.perform(pages_url).body
  pages_doc = Nokogiri::HTML(html)
end

#Занесение ссылки на каждый продукт текущей страницы категории в массив
all_url = pages_doc.xpath("//a[@class ='product_img_link product-list-category-img']//@href")
#Цикл по каждой странице с продуктом из текущего набора
puts "Начало обработки продуктов..."
all_url.each do |prod|
#Открытие ссылки на конкретный продукт
  page_url = prod
  html = Curl::Easy.perform(page_url).body
  page_doc = Nokogiri::HTML(html)
  #Вычисление названия продукта, ссылки на картинку, различных весовок/размерностей, и цен для каждой весовки/размерности
  prod_name = page_doc.xpath("//h1")
  prod_img = page_doc.xpath("//span[@id='view_full_size']//@src")
  prod_size = page_doc.xpath("//span[@class='radio_label']")
  prod_value = page_doc.xpath("//span[@class='price_comb']")#map do |produ_value|
      #/\d+[.,]\d+/.match(produ_value.text)
  #end
  #Цикл по каждой весовке/размерности
  for prod in 0..prod_size.length() - 1
    #занесение собранной информации о товаре в специальную переменную и запись этих данных в файл
    prod_full = "#{prod_name.text} - #{prod_size[prod].text}", prod_value[prod].text, prod_img.text
    csv_line << prod_full
  end
end
puts "Все продукты страницы обработаны, данные внесены в файл."
if i == page_count
  puts "Обработка всех страниц завершена."
else puts "Переход к следующей странице..."
end
end
end
puts "Файл успешно сохранён, результат работы программы: #{CSV_PATH} "
