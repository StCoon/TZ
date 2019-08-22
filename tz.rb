require 'open-uri'
require 'nokogiri'
require 'csv'

#открытие ссылки с категорией продукта
main_page_url = "https://www.petsonic.com/snacks-huesos-para-perros"
html = open(main_page_url)
main_page_doc = Nokogiri::HTML(html)

#Вычисление количества страниц в категории продукта
product_count = main_page_doc.xpath("//*[@class='heading-counter']").text.to_i
page_count = product_count % 25 == 0 ? product_count / 25 : product_count / 25 + 1

#Открытие файла, для записи информации
CSV.open("data", "wb") do |csv_line|
  csv_line << %w('Название' 'Цена' 'Изображение')
#Цикл по всем страницам с продуктом
(1 .. page_count).each do |i|
#Открытие отдельных страниц с продуктами категории
pages_url = "https://www.petsonic.com/snacks-huesos-para-perros/?p=#{i}"
html = open(pages_url)
pages_doc = Nokogiri::HTML(html)
#Занесение ссылки на каждый продукт текущей страницы категории в массив
all_url = pages_doc.xpath("//a[@class ='product_img_link product-list-category-img']//@href")
#Цикл по каждой странице с продуктом из текущего набора
all_url.each do |prod|
#Открытие ссылки на конкретный продукт
  page_url = prod
  html = open(page_url)
  page_doc = Nokogiri::HTML(html)
  #Вычисление названия продукта, ссылки на картинку, различных весовок/размерностей, и цен для каждой весовки/размерности
  prod_name = page_doc.xpath("//h1")
  prod_img = page_doc.xpath("//span[@id='view_full_size']//@src")
  prod_size = page_doc.xpath("//span[@class='radio_label']")
  prod_value = page_doc.xpath("//span[@class='price_comb']")
  #Цикл по каждой весовке/размерности
  for prod in 0..prod_size.length() - 1
    #занесение собранной информации о товаре в специальную переменную и запись этих данных в файл
    prod_full = ["#{prod_name.text} - #{prod_size[prod].text}", prod_value[prod].text, prod_img.text]
    csv_line << [prod_full]
  end
end
end
end
