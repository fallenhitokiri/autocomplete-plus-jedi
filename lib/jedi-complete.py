# -*- coding: utf-8 -*-
import os
import sys
import json

sys.path.append(os.path.realpath(__file__))

import jedi


if __name__ == "__main__":
    # argv1 = script
    # argv2 = line
    # argv3 = col
    try:
        source = sys.argv[1]
        line = int(sys.argv[2])
        col = int(sys.argv[3])
        project_path = sys.argv[4]

        sys.path.append(project_path)

        script = jedi.api.Script(
            source=source,
            line=line + 1,
            column=col,
        )

        completions = list()

        for completion in script.completions():
            completions.append({
                "name": completion.name,
                "description": completion.description,
                "docstring": completion.docstring(),
            })

        print(json.dumps(completions))
    except:
        print([])
