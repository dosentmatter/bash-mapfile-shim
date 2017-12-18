# Required to set variables up one call-stack
if [[ -f ./upvars.bash ]]; then
  . ./upvars.bash
fi

# use mapfile_function if mapfile not found
mapfile() {
  if type -f mapfile &>/dev/null; then
    command mapfile "$@"
  else
    mapfile_function "$@"
  fi
}

# Behaves like bash 4.x mapfile.
mapfile_function() {
  local DELIM=$'\n'
  local REMOVE_TRAILING_DELIM='false'
  local OUTPUT_ARRAY_NAME='MAPFILE'

  local OPTIND OPTARG OPTERR
  local option
  OPTERR=0
  while getopts ':d:n:O:s:tu:C:c:' option; do
    case "$option" in
      d)
        DELIM=$OPTARG
        ;;
      t)
        REMOVE_TRAILING_DELIM='true'
        ;;
      :)
        echo "Option requires an argument: -$OPTARG" >&2
        return 1
        ;;
      \?)
        echo "Illegal option: -$OPTARG" >&2
        return 2
        ;;
      ?)
        echo "Option unimplemented: -$option" >&2
        return 3
        ;;
    esac
  done

  shift "$((OPTIND - 1))"

  if (($# >= 1)); then
    OUTPUT_ARRAY_NAME=$1
  fi

  local output_array=()
  local null_end='false'
  local REPLY
  if [[ -n "$DELIM" ]]; then # stops at first null when DELIM is not null
    IFS= read -r -d '' && null_end='true'
  fi
  while IFS= read -r -d "$DELIM"; do
    if [[ "$REMOVE_TRAILING_DELIM" = 'true' ]]; then
      output_array+=("$REPLY")
    else
      output_array+=("$REPLY$DELIM")
    fi
  done < <(
    if [[ -n "$DELIM" ]]; then
      echo -n "$REPLY"
      [[ "$null_end" = 'true' ]] && printf '%b' '\0'
    else
      cat
    fi
  )
  if [[ -n "$REPLY" ]] || [[ "$null_end" = 'true' ]]; then
    output_array+=("$REPLY")
  fi

  local "$OUTPUT_ARRAY_NAME" &&
  upvars -a"${#output_array[@]}" "$OUTPUT_ARRAY_NAME" "${output_array[@]}"
}

# mapfile according to word splitting rules.
# This isn't used by the shim.
# Empty lines aren't included in array if
# DELIM is whitespace (space, tab, newline) or null.
mapfile_IFS() {
  local DELIM=$'\n'
  local REMOVE_TRAILING_DELIM='false'
  local OUTPUT_ARRAY_NAME='MAPFILE'

  local OPTIND OPTARG OPTERR
  local option
  OPTERR=0
  while getopts ':d:n:O:s:tu:C:c:' option; do
    case "$option" in
      d)
        DELIM=$OPTARG
        ;;
      t)
        REMOVE_TRAILING_DELIM='true'
        ;;
      :)
        echo "Option requires an argument: -$OPTARG" >&2
        return 1
        ;;
      \?)
        echo "Illegal option: -$OPTARG" >&2
        return 2
        ;;
      ?)
        echo "Option unimplemented: -$option" >&2
        return 3
        ;;
    esac
  done

  shift "$((OPTIND - 1))"

  if (($# >= 1)); then
    OUTPUT_ARRAY_NAME=$1
  fi

  local output_array=()
  local null_end='false'
  local delim_end='false'
  local REPLY
  local array_front
  local array_last
  if [[ -n "$DELIM" ]]; then
    IFS= read -r -d '' && null_end='true'
    [[ "$REPLY" = *"$DELIM" ]] && delim_end='true'
    IFS=$DELIM read -r -d '' -a 'output_array' < <(
      echo -n "$REPLY"
      [[ "$null_end" = 'true' ]] && printf '%b' '\0'
    )

    if [[ "$REMOVE_TRAILING_DELIM" = 'false' ]]; then
      array_front=("${output_array[@]:0:${#output_array[@]} - 1}")
      array_last=${output_array[${#output_array[@]} - 1]}

      array_front=("${array_front[@]/%/$DELIM}")
      if [[ "$delim_end" = 'true' ]]; then
        array_last+=$DELIM
      fi

      output_array=("${array_front[@]}" "$array_last")
    fi
  else
    while IFS=$DELIM read -r -d ''; do
      # no need to append null trailing delim because vars can't hold null
      [[ -n "$REPLY" ]] && output_array+=("$REPLY")
    done
    [[ -n "$REPLY" ]] && output_array+=("$REPLY")
  fi

  local "$OUTPUT_ARRAY_NAME" &&
  upvars -a"${#output_array[@]}" "$OUTPUT_ARRAY_NAME" "${output_array[@]}"
}
