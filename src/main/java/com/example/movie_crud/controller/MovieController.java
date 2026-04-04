package com.example.movie_crud.controller;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.movie_crud.dto.MovieDto;
import com.example.movie_crud.repository.MovieRepository;

@Controller

public class MovieController {
	
	@Autowired
	
	MovieRepository movieRepository;
	
	@GetMapping("/")
	public String loadMain() {
		return "main.html";
	}
	@GetMapping("/insert")
	public String loadInsertFrom() {
		return "insert.html";
	}
	@PostMapping("/insert")
	public String saveRecord(MovieDto movieDto ,ModelMap map)
	{
		movieRepository.save(movieDto);
		map.put("message", "movie added successfully");
		return "main.html";

} 
	@GetMapping("/fetch")
	public String fetch(ModelMap map) {
		List<MovieDto> list=movieRepository.findAll();
		if(list.isEmpty()) {
			map.put("message", "no records Present");
			return "main.html";
		}
		map.put("movies", list);
		return "fetch.html";
	}
	
//	@GetMapping("/delete")
//	public String delete(@RequestParam long id)
//	{
//		movieRepository.deleteById(id);
//		return "redirect:/fetch";
//	} 
	
	@GetMapping("/delete")
	public String removeById(@RequestParam long id, ModelMap map) {
//		System.out.println(id);
		movieRepository.deleteById(id);
		map.put("message", "record deleted");
		return fetch(map);
	}
	
	////1
	@GetMapping("/update")
	public String getUpdate(@RequestParam long id, ModelMap map) {
		Optional<MovieDto> o =movieRepository.findById(id);
		//MovieDto movieDto=o.get();
		map.put("movie", o.get());
		return "update.html";
	}
	
	/////2
	@PostMapping("/update")
	public String update(@ModelAttribute MovieDto movieDto) {
		movieRepository.save(movieDto);
		return "redirect:/fetch";
		
	}


}