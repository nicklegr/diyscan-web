# coding: utf-8

# 文字数が少ないものは編集距離を使わない方がいいかも

# 2文字レシピ
# オノ
# あみ
# たる
# そり
# まき
# かめ
# どら
# おり
# みの
# つき

# 3文字レシピ
# はしご
# たきび
# かかし
# もくば
# すばこ
# やたい
# わなげ
# デコイ
# サイロ
# せきひ
# はっぱ
# いろり
# せいろ
# おちば

require "pp"
require "json"
require "damerau-levenshtein"

class ResultParser
  def initialize
    @recipe_names = File.readlines("recipe_list.txt").map(&:rstrip).freeze
    @recipe_chars = @recipe_names.join.chars.uniq.sort.join.freeze
    @recipe_char_regex = /[#{@recipe_chars}]+/.freeze
  end

  def parse(json)
    data = JSON.parse(json)
    list = data.chunk{|e| e["detected"]}.map do |detected, frames|
      if detected
        frames.map do |e|
          clean_str = cleanup_str(e["text"])
          puts "#{clean_str} -> #{nearest_recipe_name(clean_str)}"

          nearest_recipe_name(clean_str)
        end
      else
        nil
      end
    end

    list
  end

  private

  def cleanup_str(str)
    # 表記ゆれしそうな文字を正規化
    str.tr("０-９ａ-ｚＡ-Ｚ", "0-9a-zA-Z")
      .scan(@recipe_char_regex)
      .join("")
  end

  def distance(str1, str2)
    # ダメラウ・レーベンシュタイン距離は文字の入れ替えも行う
    # 純粋なレーベンシュタイン距離は入れ替えを行わない
    # OCRなので、文字の入れ替えは発生しにくいと想定して後者を使う
    block_size = 0
    max_distance = 10
    DamerauLevenshtein.distance(str1, str2, block_size, max_distance)
  end

  def nearest_recipe_name(str)
    cand = @recipe_names.min_by do |e|
      distance(str, e)
    end

    d = distance(str, cand)

    # 編集で全然別の名前に変わってるものは却下
    if d >= str.size / 2
      nil
    else
      cand
    end
  end
end

parser = ResultParser.new
pp parser.parse(File.read("test.json"))
