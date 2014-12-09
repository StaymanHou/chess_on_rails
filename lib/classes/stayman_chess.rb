class StaymanGame < Chess::Game
  def to_s
    super.gsub(/\e\[(\d+)m/, '')
  end

  def self.load_pgn(pgn_str)
    tmp_pgn_file = Tempfile.new('pgn')
    tmp_pgn_file.write(pgn_str)
    byebug
    begin
      game = super.load_pgn(tmp_pgn_file.path)
    rescue Exception => e
      fail e
    ensure
      tmp_pgn_file.unlink
    end
    game
  end

  def pgn
    tmp_pgn_file = Tempfile.new('pgn')
    super.write(tmp_pgn_file)
    pgn_str = tmp_pgn_file.read
    tmp_pgn_file.unlink
    pgn_str
  end
end
