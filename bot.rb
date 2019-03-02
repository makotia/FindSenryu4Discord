require 'pp'
require_relative './lib/require.rb'

bot = @bot

bot.ready do
  bot.game = '川柳&短歌検出'
end

bot.message do |event|
  config = @config
  author_id = event.author.id
  if author_id == !config['discord']['client_id']
    return
  elsif event.server == nil
    event.send_message('個チャはダメです')
  elsif event.content == "詠め"
    ikkus = []
    @collection.find('server.id' => event.server.id).each { |row|
      ikkus.push(row['sentence'])
    }
    event.send_message("ここで一句\n「#{ikkus.shuffle.shuffle.shuffle.sample[0]} #{ikkus.shuffle.shuffle.shuffle.sample[1]} #{ikkus.shuffle.shuffle.shuffle.sample[2]}」")
    @redis.set event.server.id, config['discord']['client_id']
  elsif event.content == "詠むな"
    last_poet = @redis.get event.server.id
    if last_poet == nil
      event.send_message('まだ誰も詠んでないぞ')
    elsif last_poet == config['discord']['client_id']
      event.send_message("最後に詠んだのは俺やぞ")
    else
      event.send_message("最後に詠んだのは<@#{@redis.get event.server.id}>やぞ")
    end
  else
    senryu = senryu(event)
    if senryu
      event.channel.send_message("<@#{author_id}> 川柳を検出しました！\n「#{senryu[:sentence].join(' ')}」") if senryu
      tanka = tanka(event)
      @redis.set event.server.id, author_id
      if tanka
        event.channel.send_message("<@#{author_id}> 短歌を検出しました！\n「#{tanka[:sentence].join(' ')}」") if tanka
      end
    end
  end
end

bot.run
