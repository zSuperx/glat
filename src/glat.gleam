import argv
import clip.{type Command}
import clip/arg
import clip/help
import file_streams/file_stream.{type FileStream}
import file_streams/file_stream_error
import gleam/bit_array
import gleam/io

type File {
  File(path: String)
}

const bufsize: Int = 10

fn command() -> Command(File) {
  clip.command({
    use path <- clip.parameter

    File(path)
  })
  |> clip.arg(arg.new("File to glat"))
}

pub fn main() -> Nil {
  let result =
    command()
    |> clip.help(help.simple("glat", "cat bat rat glat"))
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(file) -> glat_file(file.path)
  }
}

fn glat_file(path: String) {
  let assert Ok(stream) = file_stream.open_read(path) as "Not a file!"

  read(stream)
}

fn read(stream: FileStream) {
  case file_stream.read_bytes(stream, bufsize) {
    Error(e) -> {
      case e {
        file_stream_error.Eof -> {
          Nil
        }
        _ -> panic
      }
    }
    Ok(n) -> {
      let assert Ok(stuff_string) = bit_array.to_string(n) as "Could not convert BitArray to String. Aborting"
      io.print(stuff_string)
      read(stream)
    }
  }
}
